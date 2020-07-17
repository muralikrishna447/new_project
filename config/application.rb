require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
require 'hashids'

Bundler.require(*Rails.groups)

module Delve
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    # We only want to insert our middleware before ActionDispatch::Static
    # in environments where config.serve_static_assets is true.
    # Everywhere else, the correct ordering of the middleware is to insert
    # before Rack::Lock. Run `rake middleware' to see the current order of
    # the middleware list if you ever need to update this.
    def self.middleware_to_insert_before
      return ActionDispatch::Static if Rails.env.development? || Rails.env.test?
      Rack::Runtime
    end

    config.enable_dependency_loading = true
    config.autoload_paths << Rails.root.join('lib')

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Too scared to do the above right now, but here's a convenient zone to use
    config.chefsteps_timezone = ActiveSupport::TimeZone.new("Pacific Time (US & Canada)")

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    # config.filter_parameters += [:password, :token]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << "#{Rails.root}/app/assets/videos"
    config.assets.paths << "#{Rails.root}/app/assets/maps"
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    config.assets.precompile << /.(?:svg|eot|woff|ttf)$/
    config.assets.paths << Rails.root.join("vendor", "assets")

    # Version of your assets, change this if you want to expire all your assets
    # config.assets.version = '9'
    # config.assets.initialize_on_precompile = false

    # Firmware locations
    # The firmware_download_host must be less than 24 chars, due to
    # restrictions on the firmware.
    config.firmware_download_host = 'dl.chefsteps.com'
    config.firmware_bucket = 'chefsteps-firmware-production'
    config.tftp_hosts = ['54.88.58.152']

    # We *do* want Rails caching
    unless Rails.env.development? || Rails.env.test?
      config.cache_store = :dalli_store
    end

    # Don't use Rack::Cache - it used to mess with our BromboneProxy and barely helped us on the upside
    # Don't actually know if it will mess with Rack::Prerender, but let's assume so.
    # require 'rack/cache'
    # config.middleware.delete Rack::Cache

    # CORS

    # config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
    #   allow do
    #     origins '*'
    #     # resource '/global-navigation', headers: :any, methods: [:get, :options]
    #     resource '*', :headers => :any, :methods => [:get, :post, :options, :head, :put, :delete]
    #   end
    # end

    # Primarily to allow fontawesome access from blog/shop/forum in Firefox
    config.middleware.insert_before Delve::Application.middleware_to_insert_before, Rack::AccessControlHeaders, /assets/


    # SSL configuration using strict: true so that only specific requests are using ssl.
    # Had to comment this out, it kept sales from actually working.
    config.middleware.insert_before Delve::Application.middleware_to_insert_before, Rack::SslEnforcer, only_environments: ['production', 'staging']
    config.middleware.use Rack::Deflater

    # Override the default list of spiders from prerender.io. They specifically don't default to including
    # googlebot, yahoo, bingbot b/c they do _escaped_fragment_ but that is now deprecated, and
    # we have plenty of experience to show their JavaScript crawling isn't doing it for us.
    crawler_user_agents = [
        'googlebot',
        'yahoo',
        'bingbot',
        'baiduspider',
        'facebookexternalhit',
        'twitterbot',
        'rogerbot',
        'linkedinbot',
        'embedly',
        'bufferbot',
        'quora link preview',
        'showyoubot',
        'outbrain',
        'pinterest',
        'developers.google.com/+/web/snippet',
        'slackbot',
        'vkShare',
        'W3C_Validator',
        'redditbot',
        'Applebot'
    ]

    # Order matters here, Prerender.io must come before FreshSteps.
    # PRERENDER_TOKEN is set only on prod heroku env variables. Can still test
    # on staging servers, it just won't cache anything.
    config.middleware.insert_before Delve::Application.middleware_to_insert_before, Rack::Prerender, {
      crawler_user_agents: crawler_user_agents,
      blacklist: '^/api',
      build_rack_response_from_prerender: lambda { |response, unused| response.header.delete('Status') },
      before_render: lambda { |env|
        Rails.logger.info("[INFO] [#{env['HTTP_X_REQUEST_ID']}] #{env['REMOTE_ADDR']} #{env['HTTP_X_FORWARDED_FOR']} Proxying prerender for: #{env['REQUEST_URI']}");
        return nil;
      }
    }

    # Coverband
    config.middleware.use Coverband::Middleware

    # Prefix each log line with a per-request UUID
    config.log_tags = [:uuid ]

    if Rails.env.test? || Rails.env.development?
      ENV["AUTH_SECRET_KEY"] = File.read("config/rsa_test.pem")
      ENV["AES_KEY"] = 'bUg7wjYZ4ygQEyqtBesU(+R9urFB+CNv'
    end

    # If you want to play with prerender.io locally, you need to:
    # (1) install the local server following instructions here: https://prerender.io/documentation/test-it
    # (2) run it on port 1337 with "export PORT=1337; node server.js"
    # (3) *Critical* run rails with "foreman start -p 3000" - otherwise you will hit https://github.com/prerender/prerender/issues/30
    # (4) Spoof your user agent to be googlebot and load any page
    if Rails.env.development?
      ENV["PRERENDER_SERVICE_URL"] = "http://localhost:1337"
    end

    # In development set to staging unless explicitely overridden
    bloom_env = ENV["BLOOM_ENV"] || Rails.env
    if Rails.env == "development"  && !ENV["BLOOM_ENV"]
      bloom_env = "staging"
    end

    shared_config = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config/shared_config.yml')))
    config.shared_config = shared_config[Rails.env]
    config.shared_config[:bloom] = shared_config[bloom_env][:bloom]

    config.cookie_domain = "." + Rails.application.config.shared_config[:chefsteps_endpoint].split(":").first
    if config.cookie_domain == '.localhost'
      config.cookie_domain = nil
    end

    # Adding conditional reaping_frequency in database configuration only for heroku workers.
    # `reaping_frequency` which is attempts to find and recover connections from dead threads.
    # Web app should continue with default database configuration as it is.
    if ENV['ENABLE_REAPER']
      def config.database_configuration
        parsed = super
        parsed[Rails.env] = {} unless parsed[Rails.env]
        parsed[Rails.env]['reaping_frequency'] = ENV['ENABLE_REAPER'].to_i
        parsed
      end
    end
  end
end
