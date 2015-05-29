class UserSurveysController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    if current_user.update_attributes(survey_results: params[:survey_results])
      interests = current_user.survey_results['interests']
      if interests && interests.include?("Sous Vide")
        email_list_signup(current_user.name, current_user.email, 'interests', '6024b56b7a')
      end
      render json: current_user.survey_results
    end
  end
end
