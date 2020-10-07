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

      def sync_subscriptions
        result = ChargeBee::Subscription.list({
                                                  "customer_id[is]" => current_api_user.id,
                                                  "status[in]" => Subscription::ACTIVE_OR_CANCELLED_PLAN_STATUSES
                                              })

        scheduled_sub_ids, next_billing = [], []
        if result
          result.each do |entry|
            scheduled_sub_ids << entry.subscription.id if entry.subscription.has_scheduled_changes && entry.subscription.status.in?(Subscription::ONLY_ACTIVE_PLAN_STATUSES)
            next_billing << Time.at(entry.subscription.next_billing_at) if entry.subscription.next_billing_at.present?
            params = {
                :plan_id => entry.subscription.plan_id,
                :status => entry.subscription.status,
                :resource_version => entry.subscription.resource_version
            }
            Subscription.create_or_update_by_params(params, current_api_user.id)
          end
        end
        serialized_user = JSON.parse(Api::UserMeSerializer.new(current_api_user).to_json)
        serialized_user['scheduled'] = list_scheduled_subscriptions(scheduled_sub_ids)
        # nearest billing date
        serialized_user['next_billing_date'] = next_billing.sort.first
        render json: serialized_user
      end

      def switch_subscription
        plan_id = Subscription.duration[params[:plan_type].to_s]
        unless plan_id
          render_api_response(400, {message: 'INVALID_PLAN_TYPE'})
          return
        end

        subscriptions = ChargeBee::Subscription.list({
          "customer_id[is]" => current_api_user.id,
          "status[in]" => Subscription::ONLY_ACTIVE_PLAN_STATUSES
        })
        latest_active_sub = subscriptions.max_by{|a| a.subscription.resource_version}&.subscription
        if latest_active_sub.blank?
          render_api_response(400, {message: 'NOT_YET_SUBSCRIBED'})
        elsif latest_active_sub.plan_id == plan_id
          remove_schedule_subscription(latest_active_sub.id)
        else
          schedule_subscription(latest_active_sub.id, plan_id)
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
          if content[:customer] && content[:customer][:id] && content[:subscription] && content[:subscription][:plan_id]
            Subscription.create_or_update_by_params(content[:subscription], content[:customer][:id])
            Rails.logger.info("chargebee_controller.webhook - updating event id=#{params[:id]} and event_type=#{params[:event_type]}")
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
        elsif current_api_user.cancelled_studio?
          render_api_response(400, {message: 'ALREADY_CANCELLED_SUBSCRIBED'})
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

      def list_scheduled_subscriptions(subscription_ids)
        subscription_ids.map do |id|
          object = ChargeBee::Subscription.retrieve_with_scheduled_changes(id)
          {
            subscription_id: id,
            plan_name: object.subscription.plan_id,
            type: Subscription.duration(object.subscription.plan_id),
            starts_at: object.subscription.next_billing_at ? Time.at(object.subscription.next_billing_at) : 'Never'
          }
        end
      end

      def schedule_subscription(subscription_id, plan_id)
        ChargeBee::Subscription.update(
          subscription_id,
          { plan_id: plan_id, end_of_term: true, prorate: false }
        )
        render_api_response(201, {message: 'SCHEDULED_SUCCESS'})
      rescue StandardError => e
        Rails.logger.error(e)
        render_api_response(500, {message: 'UPDATE_FAILED'})
      end

      def remove_schedule_subscription(subscription_id)
        ChargeBee::Subscription.remove_scheduled_changes(subscription_id)
        render_api_response(201, {message: 'SCHEDULED_SUCCESS'})
      rescue StandardError => e
        Rails.logger.error(e)
        render_api_response(500, {message: 'UPDATE_FAILED'})
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
