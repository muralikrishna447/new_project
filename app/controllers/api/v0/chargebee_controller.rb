module Api
  module V0
    class ChargebeeController < BaseController

      before_action :ensure_authorized

      before_action :webhook_authorize, :only => [:webhook]
      skip_before_action :log_current_user, :only => [:webhook]
      skip_before_action :ensure_authorized, :only => [:webhook]

      rescue_from ChargeBee::InvalidRequestError, with: :render_invalid_chargebee_request

      GIFT_CLAIM_LIMIT = 30

      def generate_checkout_url
        if params[:is_gift]
          # create customer if necessary
          begin
            ChargeBee::Customer.retrieve(current_api_user.id)
          rescue ChargeBee::InvalidRequestError => e
            Rails.logger.info("ChargebeeController.generate_checkout_url no customer found for user.id=#{current_api_user.id} creating the customer now, e=#{e.inspect}")
            ChargeBee::Customer.create({
                                           :id => current_api_user.id,
                                           :email => current_api_user.email
                                       })
          end

          data = {
              :subscription => {
                  :plan_id => params[:plan_id]
              },
              :gifter => {
                  :customer_id => current_api_user.id
              }
          }

          result = ChargeBee::HostedPage.checkout_gift(data)
          render_api_response(200, result.hosted_page)
        else
          studio_pass_checkout
        end

      end

      def create_portal_session
        result = ChargeBee::PortalSession.create({ :customer => { :id => current_api_user.id } })
        render_api_response(200, result.portal_session)
      end

      def update_payment_method_session
        result = ChargeBee::HostedPage.manage_payment_sources({
                                                                 :customer => {
                                                                     :id => current_api_user.id
                                                                 }
                                                             })
        render_api_response(200, result.hosted_page)
      end

      def fetch_active_or_latest_sub(user_id)
        result = ChargeBee::Subscription.list({
                                                  "customer_id[is]" => user_id,
                                                  "status[in]" => Subscription::ACTIVE_OR_CANCELLED_PLAN_STATUSES
                                              })
        return nil unless result.count != 0

        # Priorities of subscription
        # 1) latest active subscription
        # 2) any one of [active, in_trial, non_renewing] subscription
        # 3) latest subscription
        latest_sub = result.max_by{|res| res.subscription.resource_version}.subscription
        latest_sub.status == 'active' ? latest_sub : ( result.detect{|res| Subscription::ACTIVE_PLAN_STATUSES.include?(res.subscription.status)}&.subscription || latest_sub )
      end
      
      def import_subscription(user_id)
        chargebee_subscription = fetch_active_or_latest_sub(user_id)
        return nil unless chargebee_subscription.present?

        params = {
            :plan_id => chargebee_subscription.plan_id,
            :status => chargebee_subscription.status,
            :resource_version => chargebee_subscription.resource_version
        }
        Subscription.create_or_update_by_params(params, user_id)
        chargebee_subscription
      end

      def sync_subscriptions
        latest_sub = import_subscription(current_api_user.id)
        next_billing = latest_sub&.next_billing_at.present? ? Time.at(latest_sub&.next_billing_at) : nil

        Rails.logger.info("Sync subscription resource_version = #{latest_sub&.resource_version} user_status=#{Subscription.duration(latest_sub&.plan_id || 'not_avail')}")
        serialized_user = JSON.parse(Api::UserMeSerializer.new(current_api_user).to_json)
        if latest_sub&.status && %w[cancelled non_renewing].exclude?(latest_sub.status)
          upcoming_subs = list_scheduled_subscriptions(current_api_user.id)
          serialized_user['scheduled'] = upcoming_subs
          Rails.logger.info("Scheduled subscriptions are having more than the limit for user #{current_api_user.id}") if upcoming_subs.length > 1
        else
          serialized_user['scheduled'] = []
        end
        # nearest billing date
        serialized_user['next_billing_date'] = next_billing
        serialized_user['current_status'] = latest_sub&.status
        serialized_user['scheduled_cancel'] = false
        case latest_sub&.status
        when 'non_renewing'
          # subscription cancelled after trail period
          serialized_user['subscription_end_date'] = Time.at(latest_sub.current_term_end)
          serialized_user['scheduled_cancel'] = true
        when 'in_trial'
          serialized_user['trail_end_date'] = Time.at(latest_sub.trial_end)
          serialized_user['scheduled_cancel'] = true if latest_sub.cancelled_at.present?
        end
        render json: serialized_user
      end

      def switch_subscription
        plan_id = Subscription.duration[params[:plan_type].to_s]
        unless plan_id
          render_api_response(400, {message: 'INVALID_PLAN_TYPE'})
          return
        end

        subscription = fetch_active_or_latest_sub(current_api_user.id)

        Rails.logger.info("Switch subscription resource_version = #{subscription&.resource_version} user_status=#{Subscription.duration(subscription&.plan_id || 'not_avail')} requested_type=#{params[:plan_type].to_s}")
        if subscription.blank?
          render_api_response(400, {message: 'NOT_YET_SUBSCRIBED'})
        elsif subscription.status == 'non_renewing'
          render_api_response(400, {message: 'CANCEL_SCHEDULED'})
        elsif subscription.plan_id == plan_id && subscription.status != 'cancelled'
          remove_schedule_subscription(subscription.id)
        else
          schedule_subscription(subscription.id, plan_id, subscription.status)
        end
      end

      def gifts
        list = ChargeBee::Gift.list({
                                        "status[in]" => ["claimed", "unclaimed"],
                                        "gift_receiver[email][is]" => current_api_user.email,
                                        :limit => GIFT_CLAIM_LIMIT
                                    })

        Rails.logger.info("ChargebeeController.gifts found #{list.count} gifts for user.id=#{current_api_user.id} and email=#{current_api_user.email}")

        if list.next_offset.present?
          Rails.logger.error("ChargebeeController.gifts exceeded limit.  limit=#{GIFT_CLAIM_LIMIT}")
          Librato.increment("ChargebeeController.gifts.exceeded_limit", {})
        end

        gifts = list.reduce({"claimed" => [], "unclaimed" => []}) do |agg, entry|
          item = {
              :subscription => {
                  :id => entry.subscription.id,
                  :plan_id => entry.subscription.plan_id,
                  :plan_quantity => entry.subscription.plan_quantity,
                  :plan_unit_price => entry.subscription.plan_unit_price,
                  :plan_amount => entry.subscription.plan_amount,
                  :currency_code => entry.subscription.currency_code
              },
              :gift => {
                  :id => entry.gift.id,
                  :status => entry.gift.status,
                  :gifter => {
                      :signature => entry.gift.gifter.signature,
                      :note => entry.gift.gifter.note
                  },
                  :claimed_time => get_claimed_time(entry.gift.gift_timelines)
              }
          }
          agg[entry.gift.status].push(item)
          agg
        end

        render_api_response(200, {results: gifts})
      end

      # Claim the specified gifts for the authenticated user
      # This happens asynchronously via resque job
      # params[:gifts] => [gift_id1, gift_id2, ...]
      def claim_gifts
        unless gift_ids_params_valid?
          render_api_response(400, { message: "Must specify at most #{GIFT_CLAIM_LIMIT} gift_ids" })
          return
        end

        gifts = params[:gift_ids].map do |gift_id|
          result = ChargeBee::Gift.retrieve(gift_id)
          {
              :gift => result.gift,
              :subscription => result.subscription
          }
        end

        invalid_gift = gifts.any? do |gift|
          invalid_email = gift[:gift].gift_receiver.email.downcase != current_api_user.email.downcase
          invalid_gift_status = gift[:gift].status != "unclaimed"

          invalid_email || invalid_gift_status
        end

        if invalid_gift
          Rails.logger.info("ChargebeeController.claim_gifts has invalid_gift gifts=#{gifts.inspect}")
          render_api_response(401, { message: "Invalid Gift Provided" })
          return
        end

        # create customer if necessary
        begin
          ChargeBee::Customer.retrieve(current_api_user.id)
        rescue ChargeBee::InvalidRequestError => e
          Rails.logger.info("ChargebeeController.claim_gifts no customer found for user.id=#{current_api_user.id} creating the customer now, e=#{e.inspect}")
          ChargeBee::Customer.create({
                                         :id => current_api_user.id,
                                         :email => current_api_user.email
                                     })
        end

        # process gifts -> promotional credits
        gifts.each do |gift|
          Rails.logger.info("Queuing ChargeBeeGiftProcessor for gift=#{gift.inspect}")
          Resque.enqueue(ChargeBeeWorkers::ChargeBeeGiftProcessor, {
             :gift_id => gift[:gift].id,
             :user_id => current_api_user.id,
             :plan_amount => gift[:subscription].plan_amount,
             :currency_code => gift[:subscription].currency_code
          })
        end

        render_api_response(200, {})
      end

      # params[:gifts] => [gift_id1, gift_id2, ...]
      def claim_complete
        unless gift_ids_params_valid?
          render_api_response(400, { message: "Must specify at most #{GIFT_CLAIM_LIMIT} gift_ids" })
          return
        end

        complete_count = ChargebeeGiftRedemptions.complete.where(:gift_id => params[:gift_ids]).count
        complete = complete_count == params[:gift_ids].length

        render_api_response(200, {complete: complete})
      end

      # https://apidocs.chargebee.com/docs/api/events
      # For now we only want to keep the subscription status in sync with what is in Chargebee
      def webhook
        content = params[:content]
        if content
          if content[:customer] && content[:customer][:id] && content[:subscription] && content[:subscription][:plan_id] && User.where(id: content[:customer][:id]).exists?
            # Subscription.create_or_update_by_params(content[:subscription], content[:customer][:id])
            Rails.logger.info("chargebee_controller.webhook - updating event id=#{params[:id]} and event_type=#{params[:event_type]}")
            import_subscription(content[:customer][:id])
            Rails.logger.info("chargebee_controller.webhook - completed event id=#{params[:id]} and event_type=#{params[:event_type]}")
          else
            Rails.logger.info("chargebee_controller.webhook - ignoring event id=#{params[:id]} and event_type=#{params[:event_type]}")
          end
        end

        render_api_response(200, {})
      end

      private

      def studio_pass_checkout
        # Key - 'ALREADY_SUBSCRIBED','ALREADY_CANCELLED_SUBSCRIBED' error message is controlled in Angluar Js,
        # and respective popup will be shown to user at checkout page.
        if current_api_user.studio?
          render_api_response(400, {message: 'ALREADY_SUBSCRIBED'})
        #elsif current_api_user.cancelled_studio?
          #render_api_response(400, {message: 'ALREADY_CANCELLED_SUBSCRIBED'})
        else
          data = {
            :subscription => {
              :plan_id => params[:plan_id].present? ? params[:plan_id] : Subscription::STUDIO_PLAN_ID
            },
            :customer => {
              :id => current_api_user.id,
              :email => current_api_user.email
            }
          }

          coupon = get_applicable_coupon
          data[:subscription][:coupon] = coupon unless coupon.blank?

          result = ChargeBee::HostedPage.checkout_new(data)
          render_api_response(200, result.hosted_page)
        end
      end

      def list_scheduled_subscriptions(user_id)
        object = nil
        begin
          object = ChargeBee::Estimate.upcoming_invoices_estimate(user_id)
        rescue ChargeBee::InvalidRequestError => e
          Rails.logger.error("Chargebee Invoice Estimate failed for #{user_id} - #{e.message}")
          Rails.logger.error(e.backtrace)
        end

        return [] unless object.present?

        object.estimate&.invoice_estimates&.map do |estimate|
          estimate&.line_items.map do |item|
            amount = (item.amount - item.discount_amount).fdiv(100)
            amount = amount.to_i == amount ? amount.to_i : amount
            {
                subscription_id: item.subscription_id,
                plan_name: item.entity_id,
                type: Subscription.duration(item.entity_id),
                starts_at: item.date_from ? Time.at(item.date_from) : 0,
                amount: amount
            }
          end
        end.flatten
      end

      def schedule_subscription(subscription_id, plan_id, status)
        options = { plan_id: plan_id, prorate: false }
        # cancelled subscription will not accept end_of_term param while updating
        options[:end_of_term] = true unless status == 'cancelled'
        ChargeBee::Subscription.update(subscription_id, options)
        render_api_response(201, {message: 'SCHEDULED_SUCCESS'})
      rescue StandardError => e
        Rails.logger.error(e)
        render_api_response(400, {message: 'UPDATE_FAILED', error_message: e.message})
      end

      def remove_schedule_subscription(subscription_id)
        ChargeBee::Subscription.remove_scheduled_changes(subscription_id)
        render_api_response(201, {message: 'SCHEDULED_SUCCESS'})
      rescue StandardError => e
        Rails.logger.error(e)
        render_api_response(400, {message: 'UPDATE_FAILED', error_message: e.message})
      end

      def render_invalid_chargebee_request(exception = nil)
        Rails.logger.error("ChargeBee::InvalidRequestError.  current_api_user.id=#{current_api_user.id} exception=#{exception}")
        render_api_response(400, {message: 'Failed to make ChargeBee request'})
      end

      # Chargebee webhook uses basic authentication
      def webhook_authorize
        auth = request.authorization()
        if auth
          mode = auth.split(' ').first.downcase
          key = auth.split(' ').last
          if mode == 'basic' && key.present? && key == chargebee_webhook_key
            return true
          end
        end
        render_unauthorized
        false
      end

      def chargebee_webhook_key
        ENV['CHARGEBEE_WEBHOOK_KEY']
      end

      def get_applicable_coupon
        if Subscription::EXISTING_PREMIUM_COUPON.present? && current_api_user.premium?
          return Subscription::EXISTING_PREMIUM_COUPON
        end

        nil
      end

      def gift_ids_params_valid?
        params[:gift_ids].present? && params[:gift_ids].kind_of?(Array) && params[:gift_ids].length <= GIFT_CLAIM_LIMIT
      end

      def get_claimed_time(gift_timeline)
        unless gift_timeline.kind_of?(Array)
          return nil
        end

        claimed = gift_timeline.find do |event|
          event.status == "claimed"
        end

        if claimed.present?
          # make this an epoch value
          claimed.occurred_at * 1000
        else
          nil
        end
      end

    end
  end
end
