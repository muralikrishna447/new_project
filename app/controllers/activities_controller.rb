class ActivitiesController < ApplicationController
  include AggressiveCaching
  expose (:activity)

  def show
    if session[:cooked_ids].nil?
      session[:cooked_ids] = []
    end
    Rails.logger.info"\n\n\n\n************* #{session.inspect}"
    @cooked_this = session[:cooked_ids].include?(activity.id.to_s)
  end

  def cooked_this
    activity = Activity.find(params[:id])
    @cooked_count = activity.cooked_this += 1
    if activity.save
      session[:cooked_ids] << params[:id]
      Rails.logger.info"\n\n\n\n************* #{session.inspect}"
      render 'cooked_success', format: :js
    end
  end
end

