module Api
  module V0
    class ChargebeeController < BaseController
      before_filter :ensure_authorized

      rescue_from ChargeBee::InvalidRequestError, with: :render_invalid_chargebee_request

      def generate_premium_url
        params = {
          :subscription => {
            :plan_id => ENV['PREMIUM_PLAN_ID'] || 'cbdemo_nuts'
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

      private

      def render_invalid_chargebee_request(exception = nil)
        Rails.logger.error("ChargeBee::InvalidRequestError.  current_api_user.id=#{current_api_user.id} exception=#{exception}")
        render_api_response(400, {message: 'Failed to make ChargeBee request'})
      end

    end
  end
end
