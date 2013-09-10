class EnrollmentsController < ApplicationController
  respond_to :json

  before_filter :authenticate_user!, only: [:create]
  before_filter :load_enrollable

  def index
    @enrollments = @enrollable.enrollments
    respond_with @enrollments
  end

  def create
    @enrollment = @enrollable.enrollments.new(params[:enrollment])
    if @enrollment.save
      respond_with @enrollment
    end
  end

private
  
  def load_enrollable
    resource, id = request.path.split('/')[1, 2]
    @enrollable = resource.singularize.classify.constantize.find(id)
  end

end