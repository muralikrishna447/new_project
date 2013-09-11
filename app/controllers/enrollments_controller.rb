class EnrollmentsController < ApplicationController

  before_filter :authenticate_user!, only: [:create]
  before_filter :load_enrollable

  def index
    @enrollments = @enrollable.enrollments
    render json: @enrollments
  end

  def create
    @enrollment = @enrollable.enrollments.new(params[:enrollment])
    @enrollment.user_id = current_user.id
    if @enrollment.save
      render json: @enrollment
    end
  end

private
  
  def load_enrollable
    resource, id = request.path.split('/')[1, 2]
    @enrollable = resource.singularize.classify.constantize.find(id)
  end

end