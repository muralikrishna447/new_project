module Api
  module V0
    class UserSurveysController < BaseController
      before_action :ensure_authorized

      def create
        if current_api_user.update(survey_results: params[:survey_results].to_unsafe_h)
          interests = current_api_user.survey_results['interests']
          if interests
            email_list_add_to_group(current_api_user.email, '4751714', interests)
          end
          render json: current_api_user.survey_results
        end
      end
    end
  end
end
