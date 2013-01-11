class ActivitiesController < ApplicationController
  expose(:activity) { Activity.find_published(params[:id], params[:token]) }
  expose(:cache_show) { params[:token].blank? }

  def show
    @cooked_this = cooked_ids.include?(activity.id)
  end

  def cooked_this
    return head :error unless params[:id].present?
    return head :ok if cooked_ids.include?(activity.id)

    @cooked_count = activity.cooked_this += 1
    if activity.save
      cooked_ids << activity.id
      render 'cooked_success', format: :js
    else
      head :error
    end
  end

  private

  def cooked_ids
    session[:cooked_ids] ||= []
  end
end

