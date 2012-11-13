module StatusHelpers
  def render_created_resource(model)
    render json: model, status: :created
  end

  def render_resource_not_found
    head :not_found
  end

  def render_destroyed_resource
    head :no_content
  end

  def render_errors(model)
    render json: model.errors, status: :unprocessable_entity
  end

  def render_unauthorized
    render text: 'not authorized', status: :unauthorized
  end
end

