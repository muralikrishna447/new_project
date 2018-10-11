require 'spork'
require 'webmock/test_unit'


Spork.prefork do
  unless ENV['DRB'].nil?
    require 'simplecov'
    SimpleCov.start 'rails' do
      coverage_dir('tmp/coverage')
    end
  end

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

    # Allow focusing on a single spec/context with the :focus tag unless were running in codeship
    unless ENV['CI']

      config.filter_run :focus
      config.run_all_when_everything_filtered = true
    end

    #adding this filter to skip shopify-related specs
    config.filter_run_excluding :skip => 'true'
    config.include Devise::TestHelpers, type: :controller
    config.extend ControllerMacros, type: :controller
    config.include Capybara::DSL
    config.include MailerMacros

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

      WebMock.reset!
      ShopifyAPI::Mock.reset
      # Aggressively stub out all Algolia calls as they happen as side effects to activity saves
      # not fun to have to turn them off every place in specs where that happens.
      WebMock.stub_request(:any, /.*\.algolia\.(io|net).*/).to_return(:body => '{ "items": [] }')

      WebMock.stub_request(:get, /http:\/\/\/bloomAPI\/encrypt\?apiKey=xchefsteps/).
        to_return(:status => 200, :body => "", :headers => {})

      WebMock.stub_request(:get, /http:\/\/\/bloomAPI\/users.*\/initial\?apiKey=xchefsteps/).
        to_return(:status => 200, :body => "", :headers => {})

      WebMock.stub_request(:post, /.*api.segment\.io.*/).
        to_return(:status => 200, :body => "", :headers => {})

      WebMock.stub_request(:post, "https://www.google-analytics.com/debug/collect").
        to_return(:status => 200, :body => '{ "hitParsingResult": [ { "valid": true } ] }', :headers => {})

      WebMock.stub_request(:post, "http://www.google-analytics.com/collect").
        to_return(:status => 200, :body => "", :headers => {})

      WebMock.stub_request(:get, /.*geoip\.maxmind\.com.*/).
                           to_return(:status => 200,
                                     :body => '
{
  "city": {
    "geoname_id": 5809844,
    "names": {
      "pt-BR": "Seattle",
      "ru": "\u0421\u0438\u044d\u0442\u043b",
      "de": "Seattle",
      "en": "Seattle",
      "es": "Seattle",
      "fr": "Seattle",
      "ja": "\u30b7\u30a2\u30c8\u30eb"
    }
  },
  "continent": {
    "code": "NA",
    "geoname_id": 6255149,
    "names": {
      "pt-BR": "Am\u00e9rica do Norte",
      "ru": "\u0421\u0435\u0432\u0435\u0440\u043d\u0430\u044f \u0410\u043c\u0435\u0440\u0438\u043a\u0430",
      "zh-CN": "\u5317\u7f8e\u6d32",
      "de": "Nordamerika",
      "en": "North America",
      "es": "Norteam\u00e9rica",
      "fr": "Am\u00e9rique du Nord",
      "ja": "\u5317\u30a2\u30e1\u30ea\u30ab"
    }
  },
  "country": {
    "iso_code": "US",
    "geoname_id": 6252001,
    "names": {
      "es": "Estados Unidos",
      "fr": "\u00c9tats-Unis",
      "ja": "\u30a2\u30e1\u30ea\u30ab\u5408\u8846\u56fd",
      "pt-BR": "Estados Unidos",
      "ru": "\u0421\u0428\u0410",
      "zh-CN": "\u7f8e\u56fd",
      "de": "USA",
      "en": "United States"
    }
  },
  "location": {
    "accuracy_radius": 5,
    "latitude": 47.6381,
    "longitude": -122.3715,
    "metro_code": 819,
    "time_zone": "America\/Los_Angeles"
  },
  "maxmind": {
    "queries_remaining": 548200
  },
  "postal": {
    "code": "98119"
  },
  "registered_country": {
    "iso_code": "US",
    "geoname_id": 6252001,
    "names": {
      "fr": "\u00c9tats-Unis",
      "ja": "\u30a2\u30e1\u30ea\u30ab\u5408\u8846\u56fd",
      "pt-BR": "Estados Unidos",
      "ru": "\u0421\u0428\u0410",
      "zh-CN": "\u7f8e\u56fd",
      "de": "USA",
      "en": "United States",
      "es": "Estados Unidos"
    }
  },
  "subdivisions": [
    {
      "iso_code": "WA",
      "geoname_id": 5815135,
      "names": {
        "en": "Washington",
        "es": "Washington",
        "fr": "Washington",
        "ja": "\u30ef\u30b7\u30f3\u30c8\u30f3\u5dde",
        "ru": "\u0412\u0430\u0448\u0438\u043d\u0433\u0442\u043e\u043d",
        "zh-CN": "\u534e\u76db\u987f\u5dde"
      }
    }
  ],
  "traits": {
    "autonomous_system_number": 7922,
    "autonomous_system_organization": "Comcast Cable Communications, LLC",
    "domain": "comcast.net",
    "isp": "Comcast Cable",
    "organization": "Comcast Cable",
    "ip_address": "174.61.186.99"
  }
}',
                                     :headers => {})

      WebMock.stub_request(:get, /.*spree-staging1\.herokuapp\.com.*/).
                           to_return(:status => 200, :body => "", :headers => {})

      # Adding Webmock, which delightfully alerts you to any live http calls happening during specs,
      # but we already have existing mock strategies for other services, so let them through.
      WebMock.disable_net_connect!(:allow => [/mixpanel/])
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end

  require 'capybara/poltergeist'
  require 'capybara/rspec'
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {js_errors: false})
    # Set debug: true to debug poltergeist
  end

  # Basically, a not-logged-in user
  Capybara.register_driver :anonymous_rack_test do |app|
    Capybara::RackTest::Driver.new(app, headers: { 'HTTP_USER_AGENT' => 'Capybara', 'HTTP_AUTHORIZATION' => '' })
  end

  Capybara.javascript_driver = :poltergeist
  Capybara.default_wait_time = 5

  # Shopify test setup
  ShopifyAPI::Mock::Fixture.path = File.join(Rails.root, 'spec', 'shopify', 'fixtures')
end

Spork.each_run do
  unless ENV['DRB'].nil?
    require 'simplecov'
    SimpleCov.start 'rails' do
      coverage_dir('tmp/coverage')
    end
  end
end

def current_path_info
  current_url.sub(%r{.*?://},'')[%r{[/\?\#].*}] || '/'
end
