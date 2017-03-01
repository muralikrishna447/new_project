source 'https://rubygems.org'
ruby "1.9.3"

gem 'rails', '3.2.16'
gem 'railties', '3.2.16'
gem 'pg'

gem 'unicorn'
gem 'memcachier'
gem 'dalli'
gem 'cache_digests'

gem "devise"
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-facebook'
gem "koala", "~> 2.5"

gem 'haml'
gem 'activeadmin'
gem 'meta_search'
gem 'decent_exposure'
gem 'newrelic_rpm'
gem 'rdiscount'
gem "friendly_id"
gem 'gravtastic'
gem 'filepicker-rails'

gem 'comma'
gem 'hashids'

gem 'librato-rails'
gem 'librato-rack'

gem 'rack-cors', require: 'rack/cors'
gem 'rack-access-control-headers'
gem "rack-timeout"
gem 'rack-proxy'
gem 'rack-host-redirect'

gem 'pg_search'                             # Postgres text search
gem 'acts-as-taggable-on'                   # Taggable models
gem 'kaminari'                              # Pagination
gem 'select2-rails'                         # Select 2
gem 'gravatar_image_tag'
gem 'httparty'
gem 'rest-client'
gem 'acts_as_revisionable'
gem 'coffee-filter'
gem 'client_side_validations'
gem 'client_side_validations-formtastic'
gem 'merit'
gem 'has_scope'
gem 'mixpanel-ruby'
gem 'cancan'
gem 'simple-rss'
gem 'active_model_serializers'
gem 'mixpanel_client'
gem 'stripe'
gem 'geokit-rails'
gem 'rack-ssl-enforcer'
gem 'redcarpet'
gem 'google-api-client'
# gem 'activerecord-postgres-hstore'
gem 'nested-hstore'
gem 'gibbon'
gem 'faraday'
gem 'nori'

gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'

gem 'json-jwt'
gem "algoliasearch-rails"
gem 'semverse', '1.2.1'

gem 'shopify_api'
gem 'attr_encrypted', '1.3.4'

# gem 'ar-octopus', :git => 'https://github.com/tchandy/octopus.git'
gem 'resque'

gem 'sanitize'

gem 'analytics-ruby', :require => "segment"

gem 'prerender_rails'
gem "paranoia", "~> 1.0"

gem 'coverband', '1.0.3'
gem 'coverband_ext', '1.0.1'

gem 'slack-notifier'

gem 'rack-attack', '4.3.0'
gem 'retriable', '2.1.0'
gem 'resque-lock', '1.1'
gem 'signifyd'

group :test do
  gem 'webmock'
  gem 'shopify-mock', :git => 'https://github.com/ChefSteps/shopify-mock', :ref => '74132ae3a471ec29cb85547987c061e3f749fd1b'
  gem 'timecop'
end


group :development do
  gem 'spring'
  gem "letter_opener"
  # Commenting out since it's not playing well with proximo
  # gem 'net-http-spy', github: "justincaldwell/net-http-spy"
  gem 'newrelic_route_check'
end

group :development, :test do
  gem "simplecov", require: false
  gem 'angularjs-rails'
  gem 'guard-resque'
  gem 'debugger'
end

group :assets, :angular, :test, :development do
  gem 'jquery-rails'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets, :angular do
  gem 'jquery-ui-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  # gem 'font-awesome-sass-rails'
  gem 'bootstrap-sass-rails'
  gem 'asset_sync'
  gem 'turbo-sprockets-rails3'
  gem 'hamlbars'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # NOTE not using gems for angular, angular-resource b/c needed minified version for perfomance
  # in develop, and for angular-ui because of https://github.com/angular-ui/angular-ui/issues/530
  # - had to hand patch file.

  gem 'uglifier', '>= 1.0.3'
  # This was out of date so I put the one I needed in vendor
  #gem 'angular-ui-bootstrap-rails'
  gem 'showdown-rails'

end

group :production do
  gem 'airbrake'
end

group :development, :test, :angular do
  # gem 'heroku'
  gem 'heroku_san'
  gem 'rspec-rails'
  gem 'spork-rails'
  gem 'jasminerice'
  gem 'fabrication'
  gem 'capybara'
  gem 'poltergeist'
  gem 'database_cleaner'
  gem 'rack-contrib'
  gem 'pry'
  gem 'binding_of_caller'
  gem 'thin'
  gem 'rails-erd'
  gem 'bullet'
  gem 'launchy'
  gem 'childprocess', '0.3.6'
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
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'
end

#force deploy
