source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'railties', '3.2.11'
gem 'pg'

gem 'unicorn'
gem 'memcachier'
gem 'dalli'

gem "devise"
gem 'oauth2'
gem 'omniauth'
gem 'omniauth-facebook'

gem 'jquery-rails'
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

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'font-awesome-sass-rails'
  gem 'bootstrap-sass-rails'
  gem 'asset_sync'
  gem 'turbo-sprockets-rails3'
  gem 'hamlbars'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
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
  gem 'rails-dev-tweaks', '~> 0.6.1'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :guard do
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-pow'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-jasmine'
  # Problems with falling back to polling
  # https://github.com/guard/listen/issues/62
  gem 'listen', '0.4.7'
  gem 'growl'
  gem 'rb-fsevent'
end

