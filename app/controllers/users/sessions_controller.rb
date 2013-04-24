class Users::SessionsController < Devise::SessionsController

  def new
    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    if params[:email]
      @signin_message = 'Looks like you already have an account!'
      self.resource.email = params[:email]
    end
    respond_with(resource, serialize_options(resource))
  end

  def create
    cookies[:returning_visitor] = true
    super
  end

end