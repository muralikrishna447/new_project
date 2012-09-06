class ActivitiesController < ApplicationController
  def show
    case params[:id]
    when 'lecture'
      render 'lecture'
    when 'step-by-step'
      render 'step_by_step'
    else
      redirect_to root_url
    end
  end
end

