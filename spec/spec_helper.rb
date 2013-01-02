require 'spork'

Spork.prefork do

  ENV["RAILS_ENV"] ||= 'test'
  # Avoid the User model from being always preloaded. See more info here:
  # https://github.com/sporkrb/spork/wiki/Spork.trap_method-Jujitsu
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.use_transactional_fixtures = false

    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true

    # Allow focusing on a single spec/context with the :focus tag.
    config.filter_run :focus
    config.run_all_when_everything_filtered = true

    config.include Devise::TestHelpers, type: :controller
    config.extend ControllerMacros, type: :controller

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:all, js: true) do
      DatabaseCleaner.strategy = :truncation
    end

    config.after(:all, js: true) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end

  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
end

Spork.each_run do

end

