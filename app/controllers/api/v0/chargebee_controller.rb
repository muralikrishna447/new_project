module Api
  module V0
    class ChargebeeController < ::Api::BaseController
      before_filter :ensure_authorized

      def generate_premium_url
        params = {
          :subscription => {
            :plan_id => ENV['PREMIUM_PLAN_ID']
          },
          :customer => {
            :id => current_user.id,
            :email => current_user.email
          }
        }

        result = ChargeBee::HostedPage.checkout_new(params)
        render :json => result.hosted_page.to_s
      end

      def create_portal_session
        result = ChargeBee::PortalSession.create({ :customer => { :id => current_user.id } })
        render :json => result.portal_session.to_s
      end

    end
  end
end
