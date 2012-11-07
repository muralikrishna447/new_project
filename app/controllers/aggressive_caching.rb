module AggressiveCaching
  extend ActiveSupport::Concern
  included do
    before_filter :configure_caching if caching_enabled
  end

  def configure_caching
    return if self.class.excluded_actions.include?(self.action_name.to_sym)
    last_modified = Version.current
    if ENV['REVISION'].present?
      fresh_when public: true, etag: "#{last_modified}-#{ENV['REVISION']}"
    end
    expires_in 10.seconds, public: true
  end

  module ClassMethods
    def exclude_from_caching(actions)
      @@excluded_actions = [actions].flatten
    end

    def excluded_actions
      @@excluded_actions || []
    end

    private
    def caching_enabled
      Rails.env.production? || (Rails.env.test? && ActionController::Base.perform_caching)
    end
  end
end
