class UserSurveysController < ApplicationController
  before_filter :authenticate_user!, only: [:update]

  def update
    if current_user.update_attributes(survey_results: params[:survey_results])
      render json: current_user.survey_results
    end
  end
end

