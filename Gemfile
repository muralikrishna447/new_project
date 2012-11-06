source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'pg'

gem 'unicorn'
gem 'memcachier'
gem 'dalli'

gem 'jquery-rails'
gem 'haml'
gem "devise"
gem 'activeadmin'
gem 'meta_search'
gem 'decent_exposure'
gem 'ranked-model'
gem 'gibbon'
gem 'newrelic_rpm'
gem 'rdiscount'

gem 'rack-cors', require: 'rack/cors'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'font-awesome-sass-rails'
  gem 'bootstrap-sass-rails'
  gem 'asset_sync'

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

