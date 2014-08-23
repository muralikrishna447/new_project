class Api::V1::ActivitiesController < ApplicationController
  has_scope :published, type: :boolean

  def index
    @activities = apply_scopes(Activity).uniq().page(params[:page]).per(12)
    render json: @activities, each_serializer: Api::ActivitySerializer
  end

end