module ActionCaching
  extend ActiveSupport::Concern

  included do
    before_filter :configure_caching if caching_enabled
  end

  def configure_caching
    return if self.class.excluded_actions.include?(self.action_name)
    self.class.caches_action self.action_name.to_sym, layout: false
  end

  module ClassMethods
    def exclude_from_action_caching(actions)
      @@excluded_actions = [actions].flatten.map(&:to_s)
    end

    def excluded_actions
      defined?(@@excluded_actions) ? @@excluded_actions : []
    end

    private
    def caching_enabled
      ActionController::Base.perform_caching
    end
  end

end
