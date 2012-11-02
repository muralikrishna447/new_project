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

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    config.use_transactional_fixtures = true

    config.infer_base_class_for_anonymous_controllers = false
  end
end

Spork.each_run do

end

