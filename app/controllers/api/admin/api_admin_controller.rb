module Api
  module Admin
    class ApiAdminController < BaseController
      before_filter :authenticate_active_admin_user!
    end
  end
end
