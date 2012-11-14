module ActionCaching
  extend ActiveSupport::Concern

  module ClassMethods
    def caches_actions(options = {})
      excluded_actions = [options.delete(:exclude)].flatten.compact
      find_actions.each do |action|
        unless !caching_enabled? || excluded_actions.include?(action)
          caches_action action, layout: false
        end
      end
    end

    private
    def find_actions
      controller_routes = Rails.application.routes.routes.select {|r| r.defaults[:controller] == controller_name}
      controller_routes.map {|r| r.defaults[:action]}
    end

    def caching_enabled?
      ActionController::Base.perform_caching
    end
  end

end
