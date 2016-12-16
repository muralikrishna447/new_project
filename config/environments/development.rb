DOMAIN = 'delve.dev'
CDN_DOMAIN = 'delve.dev'

Delve::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
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
  logger = Logger.new(STDOUT)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime.strftime("%Y-%m-%dT%H:%M:%S.%L")} #{severity} - #{msg}\n"
  end
  config.logger = logger

  # Uncomment the following line to get request IDs in the log message
  #config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.filepicker_rails.api_key = "ANAsscmHGSKqZCHObvuK6z"

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.sass.preferred_syntax = :sass

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
    Bullet.airbrake = false
  end
  ENV["REDISTOGO_URL"] = 'redis://localhost:6379'

  config.middleware.use PrettyJsonResponse

  AlgoliaSearch.configuration = {application_id: 'JGV2ODT81S', api_key: 'c534846f01761db79637ebedc4bde21a'}

  config.mailchimp = {
    :api_key => '4494fae45457c6a2c4d1f3ba59609353-us12',
    :list_id => '5f55993b84',
    :premium_group_id => '757',
    :joule_group_id => '1481',
    :email_preferences_group_id => '9505',
    :email_preferences_group_default => ["Thing 1", "Thing 2"]
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
  Librato::Metrics.authenticate(
    ENV['LIBRATO_USER'],
    ENV['LIBRATO_TOKEN'],
  )
end
