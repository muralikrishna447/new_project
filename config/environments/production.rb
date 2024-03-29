DOMAIN = 'www.chefsteps.com'
CDN_DOMAIN = 'd1w42w8pbelamn.cloudfront.net'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  config.log_level = (ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].downcase : 'info').to_sym
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{severity}] #{msg}\n"
  end
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "https://d1w42w8pbelamn.cloudfront.net"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( print.css styleguide.css global_navigation.css forum_nav.css active_admin.css active_admin/print.css navigation_bootstrap.js active_admin.js jquery.mjs.nestedSortable.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: DOMAIN }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: 'chefsteps',
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'chefsteps.com',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.filepicker_rails.api_key = "AxKnxZ4VIRRWQy1V37ZYNz"

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  DISQUS_SHORTNAME = "chefstepsproduction"

  config.middleware.insert_before Delve::Application.middleware_to_insert_before, Rack::Cors do
    allow do
      origins 'https://www.chefsteps.com', 'https://shop.chefsteps.com',
              'https://www.chocolateyshatner.com', 'https://shop.chocolateyshatner.com',
              'https://www.vanillanimoy.com', 'https://shop.vanillanimoy.com'
      resource '/api/v0/*', :headers => :any, :methods => [:get, :post, :options, :head, :put, :delete], :credentials => true
    end
    allow do
      origins '*'
      resource '/api/v0/*', :headers => :any, :methods => [:get, :post, :options, :head, :put, :delete], :credentials => false
    end
  end

  AlgoliaSearch.configuration = { application_id: 'JGV2ODT81S', api_key: ENV['ALGOLIA_API_KEY'] }

  config.mailchimp = {
    :api_key => ENV['MAILCHIMP_API_KEY'],
    :list_id => 'a61ebdcaa6',
    :survey_group_id => '8152'
  }
  ENV['MAILCHIMP_API_KEY'] = config.mailchimp[:api_key] # for gibbon

  Rails.application.routes.default_url_options[:protocol] = 'https'

  # New Code
  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "rails5-2_sample_#{Rails.env}"

  config.action_mailer.perform_caching = false
end
