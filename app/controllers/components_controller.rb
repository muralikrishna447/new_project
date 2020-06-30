class ComponentsController < ApplicationController
  before_action :authenticate_active_admin_user!
  layout 'components'
  def index

  end
end
