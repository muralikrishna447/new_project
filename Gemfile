source 'https://rubygems.org'
ruby '2.3.3'

gem 'rails', '4.2.0'
gem 'railties', '4.2.0'
gem 'pg', '0.17.1'

gem 'unicorn'
gem 'memcachier'
gem 'dalli'
gem 'cache_digests'

gem "devise"
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-facebook'
gem "koala"

gem 'haml'
gem 'activeadmin'
gem 'decent_exposure'
gem 'newrelic_rpm'
gem 'rdiscount'
gem "friendly_id"
gem 'gravtastic'
gem 'filepicker-rails'

gem 'comma'
gem 'hashids'

gem 'librato-rails', '1.4.1'
gem 'librato-rack', '1.0.1'

gem 'rack-cors', require: 'rack/cors'
gem 'rack-access-control-headers'
gem "rack-timeout", '0.1.1'
gem 'rack-proxy', '0.5.17'
gem 'rack-host-redirect'

gem 'pg_search'                             # Postgres text search
gem 'acts-as-taggable-on'                   # Taggable models
gem 'kaminari'                              # Pagination
gem 'select2-rails', '3.5.2'                         # Select 2
gem 'gravatar_image_tag'
gem 'httparty'
gem 'rest-client'
# gem 'acts_as_revisionable'
# gem 'coffee-filter'  ref : https://github.com/paulnicholson/coffee-filter
# gem 'client_side_validations'
# gem 'client_side_validations-formtastic'
gem 'merit', '2.0.0'
gem 'has_scope'
gem 'mixpanel-ruby'
gem 'cancan'
gem 'simple-rss'
gem 'active_model_serializers', '0.9.3'
gem 'mixpanel_client'
gem 'stripe'
gem 'geokit-rails'
gem 'rack-ssl-enforcer'
gem 'redcarpet'
gem 'google-api-client'
# gem 'activerecord-postgres-hstore'
gem 'nested-hstore'
gem 'gibbon', '1.1.5'
gem 'faraday', '0.9'
gem 'nori'

gem 'aws-sdk-v1', '1.59.1'
gem 'aws-sdk', '2.11.374'

gem 'json-jwt', '0.7.1'
gem "algoliasearch-rails"
gem 'semverse', '1.2.1'

gem 'shopify_api'
gem 'protected_attributes'
gem 'attr_encrypted', '1.3.5'

# gem 'ar-octopus', :git => 'https://github.com/tchandy/octopus.git'
gem 'resque'

gem 'sanitize'

gem 'analytics-ruby', :require => "segment"

gem 'prerender_rails'
gem 'paranoia', '~> 2.2'

gem 'coverband', '1.0.3'
gem 'coverband_ext', '1.0.1'

gem 'slack-notifier'

gem 'rack-attack'
gem 'retriable'
gem 'resque-lock'
gem 'signifyd'
gem 'peddler'

gem 'quickbase_client'

gem 'ruby-protocol-buffers' # JR QR Codes

gem 'chargebee', '~>2'

group :test do
  gem 'webmock'
  gem 'test-unit'
  gem 'shopify-mock', :git => 'https://github.com/ChefSteps/shopify-mock', :ref => '74132ae3a471ec29cb85547987c061e3f749fd1b'
  gem 'timecop'
  gem 'rspec-collection_matchers'
end


group :development do
  gem 'spring'
  gem "letter_opener"
  #gem 'active_record_query_trace'
  # Commenting out since it's not playing well with proximo
  # gem 'net-http-spy', github: "justincaldwell/net-http-spy"
  gem 'newrelic_route_check'
end

group :development, :test do
  gem "simplecov", require: false
  gem 'angularjs-rails'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.5'


# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem 'jquery-ui-rails'
gem 'compass-rails'
gem 'font-awesome-sass-rails'
gem 'bootstrap-sass-rails-rtl'
gem 'twitter-bootstrap-rails'
gem 'bootstrap-sass-rails'
gem 'asset_sync', '0.5.0'
#gem 'turbo-sprockets-rails3'
# # gem 'hamlbars'
#
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'url_safe_base64'
gem 'devise-token_authenticatable'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'showdown-rails'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-deprecated_finders', require: 'active_record/deprecated_finders'

group :development, :test, :angular do
  gem 'heroku_san'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'spork-rails',"~> 4.0"
  gem 'jasminerice', :git => 'https://github.com/bradphelan/jasminerice.git'
  gem 'fabrication'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'rack-contrib'
  gem 'pry'
  gem 'thin'
  gem 'rails-erd'
  gem 'bullet'
  gem 'launchy'
  gem 'childprocess'
end

group :development, :angular do
  gem 'better_errors' #moving this out of tests for segfault problems.
end

group :guard do
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-pow'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-jasmine'
  gem 'listen'
  gem 'growl'
  gem 'terminal-notifier-guard'
  gem 'guard-resque'
end

#force deploy
