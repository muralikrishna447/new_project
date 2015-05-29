class UserSurveysController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    if current_user.update_attributes(survey_results: params[:survey_results])
      interests = current_user.survey_results['interests']
      if interests && interests.include?("Sous Vide")
        puts "Lets add them to the sous vide mailchimp list"
      end
      render json: current_user.survey_results
    end
  end
end
