module CacheTesting
  extend ActiveSupport::Concern

  module ClassMethods
    def with_caching(on = true)
      caching = ActionController::Base.perform_caching
      ActionController::Base.perform_caching = on
      yield
    ensure
      ActionController::Base.perform_caching = caching
    end
  end
end
