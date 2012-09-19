class ActivitiesController < ApplicationController
  include AggressiveCaching
  expose(:activity)

  def show
    session[:cooked_ids] = []
    session[:cooked_ids] ||= []
    @cooked_this = session[:cooked_ids].include?(activity.id)
  end

  def cooked_this
    id = params[:id].to_i
    return unless id > 0
    return if session[:cooked_ids] && session[:cooked_ids].include?(id)

    activity = Activity.find_by_id(id)
    return if activity.nil?

    @cooked_count = activity.cooked_this += 1
    if activity.save
      session[:cooked_ids] ||= []
      session[:cooked_ids] << id
      render 'cooked_success', format: :js
    end
  end
end

