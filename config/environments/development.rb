DOMAIN = 'delve.dev'
CDN_DOMAIN = 'delve.dev'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: DOMAIN }
  ENV['SENDGRID_PASSWORD'] = 'RzKSS9^xaS5i'
  config.action_mailer.smtp_settings = {
    user_name: 'chefsteps',
    password: ENV['SENDGRID_PASSWORD'],
    domain: 'chefsteps.com',
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # Heroku provides this for us in staging/prod, but timestamps are
  # useful in development
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime.strftime("%Y-%m-%dT%H:%M:%S.%L")} #{severity} - #{msg}\n"
  end
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Uncomment the following line to get request IDs in the log message
  #config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  # config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.filepicker_rails.api_key = "ANAsscmHGSKqZCHObvuK6z"

  # Do not compress assets
  # config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.sass.preferred_syntax = :sass

  # Firmware locations
  # The firmware_download_host must be less than 24 chars, due to
  # restrictions on the firmware.
  config.firmware_download_host = 'dl-test.chefsteps.com'
  config.firmware_bucket = 'chefsteps-firmware-staging'
  config.tftp_hosts = ['52.203.247.52']

  # DISQUS_SHORTNAME = "delvestaging"
  DISQUS_SHORTNAME = "chefstepsproduction"

  # Bullet Gem
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = false
    Bullet.bullet_logger = false
    Bullet.console = false
    Bullet.growl = false
    # Bullet.xmpp = { :account => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }
    Bullet.rails_logger = true
  end
  ENV["REDIS_URL"] = 'redis://localhost:6379'

  config.middleware.use PrettyJsonResponse

  AlgoliaSearch.configuration = {application_id: 'JGV2ODT81S', api_key: 'c534846f01761db79637ebedc4bde21a'}

  config.mailchimp = {
    :api_key => '4494fae45457c6a2c4d1f3ba59609353-us12',
    :list_id => '5f55993b84'
  }
  ENV['MAILCHIMP_API_KEY'] = config.mailchimp[:api_key] # for gibbon

  ENV['AWS_ACCESS_KEY_ID'] = 'AKIAI3LT2ZFRGC25RWQA'
  ENV['AWS_SECRET_ACCESS_KEY'] = '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'

  # This staging domain and secret are only good for 30 days from 7/7/2016; if necessary you could create
  # another free account and do this again. They only provide sandboxes for enterprise plans.
  ENV['ZENDESK_DOMAIN']     = "chefsteps-staging.zendesk.com"
  ENV['ZENDESK_MAPPED_DOMAIN'] = "chefsteps-staging.zendesk.com"
  ENV['ZENDESK_SHARED_SECRET'] = "eGQwqBQT7MuyvLxUKm1940fSrqSMDHqnimWfxlWmkUfNccf2"
  ENV['GA_TRACKING_ID'] = 'UA-34555970-6'

  ENV['OAUTH_SECRET'] = "randomstring"

  Librato::Metrics.authenticate(
    ENV['LIBRATO_USER'],
    ENV['LIBRATO_TOKEN'],
  )

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # New Code
  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  config.action_mailer.perform_caching = false

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end
