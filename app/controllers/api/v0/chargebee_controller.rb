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
                                        "gift_receiver[email][is]" => current_api_user.email
                                    })
        list.each do |entry|
          Rails.logger.info("#{entry.gift.inspect}")
          Rails.logger.info("#{entry.subscription.inspect}")
        end

        render_api_response(200, list)
      end

      def claim_gifts
        # TODO
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
