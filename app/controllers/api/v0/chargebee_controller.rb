module Api
  module V0
    class ChargebeeController < BaseController

      before_filter :ensure_authorized

      before_filter :webhook_authorize, :only => [:webhook]
      skip_before_filter :log_current_user, :only => [:webhook]
      skip_before_filter :ensure_authorized, :only => [:webhook]

      rescue_from ChargeBee::InvalidRequestError, with: :render_invalid_chargebee_request

      def generate_checkout_url
        if params[:is_gift]
          data = {
              :subscription => {
                  :plan_id => params[:plan_id]
              },
              :gifter => {
                  :customer_id => current_api_user.id,
              }
          }

          result = ChargeBee::HostedPage.checkout_gift(data)
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
          if coupon.present?
            data[:subscription][:coupon] = coupon
          end

          result = ChargeBee::HostedPage.checkout_new(data)
        end

        render_api_response(200, result.hosted_page)
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
        result = ChargeBee::Subscription.list({"customer_id[is]" => current_api_user.id})

        if result
          result.each do |entry|
            params = {
                :plan_id => entry.subscription.plan_id,
                :status => entry.subscription.status,
                :resource_version => entry.subscription.resource_version
            }
            Subscription.create_or_update_by_params(params, current_api_user.id)
          end
        end

        render json: current_api_user, serializer: Api::UserMeSerializer
      end

      def unclaimed_gifts
        list = ChargeBee::Gift.list({
                                        "status[is]" => "unclaimed",
                                        "gift_receiver[email][is]" => current_api_user.email,
                                        :limit => 3
                                    })

        gifts = list.map do |entry|
          {
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
                :gifter => {
                  :signature => entry.gift.gifter.signature,
                  :note => entry.gift.gifter.note
                }
              }
          }
        end

        render_api_response(200, gifts)
      end

      # Claim the specified gifts for the authenticated user
      # params[:gifts] => [gift_id1, gift_id2, ...]
      def claim_gifts
        if !params[:gift_ids].present? || !params[:gift_ids].kind_of?(Array)
          render_api_response(400, { message: "Must specify gift_ids" })
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
          invalid_email = gift[:gift].gift_receiver.email != current_api_user.email
          invalid_gift_status = gift[:gift].status != "unclaimed"

          invalid_email || invalid_gift_status
        end

        if invalid_gift
          render_api_response(401, { message: "Invalid Gift Provided" })
          return
        end

        # create customer if necessary
        begin
          ChargeBee::Customer.retrieve(current_api_user.id)
        rescue ChargeBee::InvalidRequestError => e
          ChargeBee::Customer.create({
                                         :id => current_api_user.id,
                                         :email => current_api_user.email
                                     })
        end

        # TODO - implement locking mechanism for all future steps in this function
        # to ensure 1 claimed gift always results in the promotional credits being applied

        # process gifts -> promotional credits
        gifts.each do |gift|
          result = ChargeBee::Gift.claim(gift[:gift].id)
          result = ChargeBee::PromotionalCredit.add({
                                                        :customer_id => current_api_user.id,
                                                        :amount => gift[:subscription].plan_amount,
                                                        :currency_code => gift[:subscription].currency_code,
                                                        :description => "Gift"
                                                    })
        end

        # TODO - device if we want to do this
        #
        # # Update the Gift Receiver(s)
        # gift_receivers = gifts.map { |g| g[:gift].gift_receiver }.keep_if { |receiver| receiver.customer_id != current_api_user.id }.uniq { |receiver| receiver.customer_id }
        # gift_receivers.each do |receiver|
        #   Rails.logger.info("receiver=#{receiver.inspect}")
        #   result = ChargeBee::Customer.update(receiver.customer_id, {
        #       :first_name => 'Gift',
        #       :last_name => 'Recipient',
        #       :email => '',
        #       :meta_data => {
        #           :gift_receiver => receiver # storing this in meta_data just in case it's needed in the future
        #       }
        #   })
        # end
        #
        # # Update the Customer object (the one that gets the promotional credits)
        # meta_data = customer.meta_data || { :gift_receiver_ids => [] }
        # gift_receiver_ids = gift_receivers.map { |receiver| receiver.customer_id }
        # meta_data[:gift_receiver_ids] = meta_data[:gift_receiver_ids].append(gift_receiver_ids).uniq
        #
        # Rails.logger.info("meta_data=#{meta_data.inspect}")
        #
        # result = ChargeBee::Customer.update(current_api_user.id, {
        #     :meta_data => meta_data
        # })

        render_api_response(200, {})
      end
      
      def create_subscription
        result = ChargeBee::Subscription.create_for_customer(current_api_user.id,{
            :plan_id => params[:plan_id].present? ? params[:plan_id] : Subscription::STUDIO_PLAN_ID,
        })

        render_api_response(200, {})
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

    end
  end
end
