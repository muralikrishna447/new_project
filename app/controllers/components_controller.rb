class ComponentsController < ApplicationController
  before_filter :authenticate_active_admin_user!
  layout 'components'
  def index

  end
end
