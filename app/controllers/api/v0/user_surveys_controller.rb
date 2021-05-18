module Api
  module V0
    class UserSurveysController < BaseController
      before_action :ensure_authorized

      def create
        if current_api_user.update(survey_results: params[:survey_results].to_unsafe_h)
          interests = current_api_user.survey_results['interests']
          if interests
            email_list_add_to_group(current_api_user.email,
                                    Rails.configuration.mailchimp[:survey_group_id],
                                    interests)
          end
          suggestion = current_api_user.survey_results['suggestion']
          if suggestion.present?
            current_api_user.suggested_recipes << SuggestedRecipe.where("lower(name) =?",
                                                                        suggestion.strip.downcase)
                                                      .first_or_create(:name=> suggestion.strip)
          end
          render json: current_api_user.survey_results
        end
      end
    end
  end
end
