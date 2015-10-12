class EnrollmentsController < ApplicationController

  before_filter :authenticate_user!, only: [:create]
  before_filter :load_enrollable

private

  def load_enrollable
    resource, id = request.path.split('/')[1, 2]
    @enrollable = resource.singularize.classify.constantize.find(id)
  end

end