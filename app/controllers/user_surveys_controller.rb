class UserSurveysController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    if current_user.update_attributes(survey_results: params[:survey_results])
      interests = current_user.survey_results['interests']
      if interests
        email_list_add_to_group(current_user.email, '8061', interests)
      end
      render json: current_user.survey_results
    end
  end
end
