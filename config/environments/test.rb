DOMAIN = "delve.dev"
CDN_DOMAIN = 'delve.dev'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  # config.serve_static_assets = true
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Enable logs for tests.  ActiveRecord logs are a bit verbose, so disabling
  # Comment out next line if you want the logs in log/test.log instead of inline in rspec output.
  config.logger = Logger.new(STDOUT)
  config.log_level = :warn
  config.after_initialize do
    ActiveRecord::Base.logger.level = Logger::WARN
  end

  # Log error messages when you accidentally call methods on nil
  # config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: DOMAIN }

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
  DISQUS_SHORTNAME = "chefstepstesting"
  ENV["REDIS_URL"] = 'redis://localhost:6379'

  # Firmware locations
  # The firmware_download_host must be less than 24 chars, due to
  # restrictions on the firmware.
  config.firmware_download_host = 'dl-test.chefsteps.com'
  config.firmware_bucket = 'chefsteps-firmware-staging'
  config.tftp_hosts = ['52.203.247.52']

  config.filepicker_rails.api_key = "BOGUS_FILEPICKER_KEY"

  AlgoliaSearch.configuration = { application_id: 'JGV2ODT81S', api_key: 'c534846f01761db79637ebedc4bde21a' }

  config.mailchimp = {
    :api_key => 'test-api-key',
    :list_id => 'test-list-id'
  }
  ENV['MAILCHIMP_API_KEY'] = config.mailchimp[:api_key] # for gibbon

  # Specifying credentials is required to keep the ruby SDK from trying to find
  # using "other ways" such as a call to 169.254.169.254 if it's running on ec2
  ENV['AWS_ACCESS_KEY_ID'] = 'NOTANACCESSKEYID'
  ENV['AWS_SECRET_ACCESS_KEY'] = 'NOTASECRETKEY'

  ENV['ZENDESK_DOMAIN']     = "imaginary-chefsteps-test.zendesk.com"
  ENV['ZENDESK_MAPPED_DOMAIN']     = "imaginary-zendesk.chefsteps.com"
  ENV['ZENDESK_SHARED_SECRET'] = "NOTHINGTOSEEHERE"

  ENV['OAUTH_SECRET'] = "randomstring"

  # Randomize the order test cases are executed.
  config.active_support.test_order = :random

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

end
