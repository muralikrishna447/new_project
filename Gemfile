source 'https://rubygems.org'
ruby "1.9.3"

gem 'rails', '3.2.14'
gem 'railties', '3.2.14'
gem 'pg'

gem 'unicorn'
gem 'memcachier'
gem 'dalli'
gem 'cache_digests'

gem "devise"
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-facebook'

gem 'haml'
gem 'activeadmin'
gem 'meta_search'
gem 'decent_exposure'
gem 'ranked-model'
gem 'newrelic_rpm'
gem 'rdiscount'
gem "friendly_id"
gem 'gravtastic'
gem 'filepicker-rails'

gem 'comma'

gem 'rack-cors', require: 'rack/cors'
gem 'rack-access-control-headers'

gem 'pg_search'                             # Postgres text search
gem 'acts-as-taggable-on'                   # Taggable models
gem 'kaminari'                              # Pagination
gem 'select2-rails'                         # Select 2
gem 'gravatar_image_tag'
gem 'httparty'
gem 'rest-client'
gem 'acts_as_revisionable'
gem 'coffee-filter'
gem 'bootstrap-wysihtml5-rails'
gem 'client_side_validations'
gem 'client_side_validations-formtastic'
gem 'split', require: 'split/dashboard'
gem 'redis'
gem 'merit'
gem 'has_scope'
gem 'mixpanel-ruby'
gem 'cancan'
gem 'simple-rss'
gem 'active_model_serializers'
gem 'mixpanel_client'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'geokit-rails'
gem 'rack-ssl-enforcer'
gem 'redcarpet'

# Gems used only for assets and not required
# in production environments by default.
group :assets, :angular do
  gem 'jquery-rails'
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

group :development, :test, :angular do
  gem 'heroku'
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
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'thin'
  gem 'rails-erd'
  gem 'bullet'
  gem 'launchy'
  gem 'childprocess', '0.3.6'
  gem 'xray-rails'
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
end

