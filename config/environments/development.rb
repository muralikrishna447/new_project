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
  config.action_mailer.raise_delivery_errors = false

  #config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :letter_opener
  # config.action_mailer.default_url_options = { host: DOMAIN }
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   port: '587',
  #   address: 'smtp.mandrillapp.com',
  #   user_name: ENV['MANDRILL_USERNAME'],
  #   password: ENV['MANDRILL_APIKEY'],
  #   doman: 'heroku.com',
  #   authentication: :plain
  # }

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

  config.bloom_api_endpoint = "http://localhost:5000"
  config.bloom_community_endpoint = "http://localhost:9001"
  # Bloom env is necessary since bloom code uses "dev" and rails env is "development"
  config.bloom_env = "dev"

  # TODO - where should this live - a helper?
  config.clientConfig = {}
  config.clientConfig[:bloom_api_endpoint] = config.bloom_api_endpoint
  config.clientConfig[:bloom_community_endpoint] = config.bloom_community_endpoint
  config.clientConfig[:bloom_env] = config.bloom_env

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

  Net::HTTP.http_logger_options = {:verbose => true, :body => true, trace: true}

  config.middleware.use PrettyJsonResponse
end
