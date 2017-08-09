module Api
  module Admin
    class ApiAdminController < BaseController
      before_filter :ensure_authorized_service_or_admin
    end
  end
end
