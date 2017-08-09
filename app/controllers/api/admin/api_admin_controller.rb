module Api
  module Admin
    class ApiAdminController < BaseController
      before_filter BaseController.make_service_or_admin_filter(['SupportTool'])
    end
  end
end
