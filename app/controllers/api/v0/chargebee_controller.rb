module Api
  module V0
    class ChargebeeController < BaseController
      before_filter :ensure_authorized

      rescue_from ChargeBee::InvalidRequestError, with: :render_invalid_chargebee_request

      def generate_premium_url
        params = {
          :subscription => {
            :plan_id => Subscription::PREMIUM_PLAN_ID
          },
          :customer => {
            :id => current_api_user.id,
            :email => current_api_user.email
          }
        }

        result = ChargeBee::HostedPage.checkout_new(params)
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
            subscription = Subscription.where(:plan_id => entry.subscription.plan_id).where(:user_id => current_api_user.id).first_or_create! do |sub|
              sub.user_id = current_api_user.id
              sub.plan_id = entry.subscription.plan_id
              sub.status = entry.subscription.status
            end

            subscription.status = entry.subscription.status
            subscription.save!
          end
        end

        render json: current_api_user, serializer: Api::UserMeSerializer
      end

      private

      def render_invalid_chargebee_request(exception = nil)
        Rails.logger.error("ChargeBee::InvalidRequestError.  current_api_user.id=#{current_api_user.id} exception=#{exception}")
        render_api_response(400, {message: 'Failed to make ChargeBee request'})
      end

    end
  end
end
