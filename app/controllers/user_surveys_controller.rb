class UserSurveysController < ApplicationController
  before_filter :authenticate_user!, only: [:update]

  def update
    
  end
end

