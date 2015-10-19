require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
# require "action_controller/railtie"
# require "action_mailer/railtie"
# require "active_resource/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'rails/all'

require 'hashids'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Delve
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**}')]
    config.autoload_paths += %w[
      lib
    ].map { |path| Rails.root.join(path) }

    # rspec generators
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :fabrication

    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << "#{Rails.root}/app/assets/videos"
    config.assets.paths << "#{Rails.root}/app/assets/maps"
    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '9'
    config.assets.initialize_on_precompile = false

    # We *do* want Rails caching
    unless Rails.env.development?
      config.cache_store = :dalli_store
    end

    # Don't use Rack::Cache - it messes with our BromboneProxy and barely helps us on the upside
    require 'rack/cache'
    config.middleware.delete Rack::Cache

    # CORS

    # config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
    #   allow do
    #     origins '*'
    #     # resource '/global-navigation', headers: :any, methods: [:get, :options]
    #     resource '*', :headers => :any, :methods => [:get, :post, :options, :head, :put, :delete]
    #   end
    # end

    # Primarily to allow fontawesome access from blog/shop/forum in Firefox
    config.middleware.insert_before ActionDispatch::Static, Rack::AccessControlHeaders, /assets/


    # SSL configuration using strict: true so that only specific requests are using ssl.
    # Had to comment this out, it kept sales from actually working.
    config.middleware.insert_before ActionDispatch::Static, Rack::SslEnforcer, only_environments: ['production', 'staging']
    config.middleware.use Rack::Deflater

    # Order matters here, Brombone must come before FreshSteps
    config.middleware.insert_before ActionDispatch::Static, 'BromboneProxy'
    config.middleware.insert_before ActionDispatch::Static, 'FreshStepsProxy'

    # Prefix each log line with a per-request UUID
    config.log_tags = [:uuid ]

    if Rails.env.test? || Rails.env.development?
      ENV["AUTH_SECRET_KEY"] = File.read("config/rsa_test.pem")
      ENV["AES_KEY"] = 'adkfj1n349ufdnc(mz&109sjp{'
    end

    # In development set to staging unless explicitely overridden
    bloom_env = ENV["BLOOM_ENV"] || Rails.env
    if Rails.env == "development"  && !ENV["BLOOM_ENV"]
      bloom_env = "staging"
    end

    shared_config = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config/shared_config.yml')))
    config.shared_config = shared_config[Rails.env]
    config.shared_config[:bloom] = shared_config[bloom_env][:bloom]
  end
end
