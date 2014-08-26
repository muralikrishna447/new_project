class Api::V1::ActivitiesController < ApplicationController
  has_scope :published, type: :boolean

  def index
    @activities = apply_scopes(Activity).uniq().page(params[:page]).per(12)
    render json: @activities, each_serializer: Api::ActivityIndexSerializer
  end

  def show
    @activity = Activity.find(params[:id])
    render json: @activity, serializer: Api::ActivitySerializer
  end

end