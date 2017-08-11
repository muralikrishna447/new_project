require_dependency 'external_service_token_checker'
module Api
  module Admin
    class ApiAdminController < BaseController
      before_filter(BaseController.make_service_or_admin_filter(
        [ExternalServiceTokenChecker::SUPPORT_SERVICE]))
    end
  end
end
