DOMAIN='www.chocolateyshatner.com'
CDN_DOMAIN = 'https://d2t0ubu4aw4rxn.cloudfront.net'

Delve::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false
  config.static_cache_control = "public, max-age=2592000"

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

  config.log_level = (ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].downcase : 'info').to_sym
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{severity}] #{msg}\n"
  end
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)


  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = "https://d2t0ubu4aw4rxn.cloudfront.net"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( print.css styleguide.css global_navigation.css forum_nav.css active_admin.css active_admin/print.css navigation_bootstrap.js active_admin.js  jquery.mjs.nestedSortable.js)

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: DOMAIN }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: 'chefsteps',
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'chocolateyshatner.com',
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

  config.filepicker_rails.api_key = "ANAsscmHGSKqZCHObvuK6z"

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Firmware locations
  # The firmware_download_host must be less than 24 chars, due to
  # restrictions on the firmware.
  config.firmware_download_host = 'dl-test.chefsteps.com'
  config.firmware_bucket = 'chefsteps-firmware-staging'
  config.tftp_hosts = ['52.203.247.52']

  DISQUS_SHORTNAME = "delvestaging"

  config.middleware.insert_before Delve::Application.middleware_to_insert_before, Rack::Cors, debug: true do
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

  AlgoliaSearch.configuration = { application_id: 'JGV2ODT81S', api_key: '09aead6e71067484d11f3f4ff0b34364' }

  #Staging mailchimp
  config.mailchimp = {
    :api_key => ENV['MAILCHIMP_API_KEY'],
    :list_id => '739b719346',
    :survey_group_id => '293870'
  }
  ENV['MAILCHIMP_API_KEY'] = config.mailchimp[:api_key] # for gibbon



  Rails.application.routes.default_url_options[:protocol] = 'https'
end
