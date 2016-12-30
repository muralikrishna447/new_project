group :nojasmine do
  guard 'livereload' do
    watch(%r{app/views/.+\.(erb|haml|slim)})
    watch(%r{app/helpers/.+\.rb})
    watch(%r{public/.+\.(css|js|html)})
    watch(%r{config/locales/.+\.yml})

    # Rails Assets Pipeline
    watch(%r{(app|vendor)/assets/\w+/(.+\.(js|html)).*})  { |m| "/assets/#{m[2]}" }
    watch(%r{^(?:app|vendor)/assets/stylesheets/(?:([^/]+)/)?(?:.+/)*(.+?)\.(?:css\.)?s[ac]ss$}) { |m| "assets/#{m[1] || m[2]}.css" }

    # jasmine
    watch(%r{spec/javascripts/spec/(.+?)\.(js\.coffee|js|coffee)$})
    watch(%r{^spec/javascripts/(.+)_spec\.(js\.coffee|js|coffee)$})
    watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)$})
  end

  guard 'pow' do
    watch('.powrc')
    watch('.powenv')
    watch('.rvmrc')
    watch('Gemfile')
    watch('Gemfile.lock')
    watch('config/application.rb')
    watch('config/environment.rb')
    watch(%r{^config/environments/.*\.rb$})
    watch(%r{^config/initializers/.*\.rb$})
  end

  guard 'spork' do
    watch('config/application.rb')
    watch('config/environment.rb')
    watch('config/routes.rb')
    watch(%r{^config/environments/.*\.rb$})
    watch(%r{^config/initializers/.*\.rb$})
    watch('spec/spec_helper.rb')
    watch(%r{^spec/support/.*\.rb$})
  end

  guard 'rspec', cli: "--debug --profile -b --color --drb --fail-fast -r support/formatters/anxious_formatter.rb -f AnxiousFormatter", bundler: false, all_on_start: false, all_after_pass: false do
    watch(%r{spec/(.*)_spec.rb})
    watch(%r{app/(.*)\.rb})                            { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{app/(.*\.haml)})                          { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{lib/(.*)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')                       { "spec" }
    watch('app/controllers/application_controller.rb') { "spec/controllers" }
  end
end

group :yesjasmine do

  guard 'jasmine', server_env: :test, server: :thin, all_on_start: false do #, jasmine_url: 'http://localhost:3000/jasmine', port: 80, all_on_start: false do
    watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$})        { "spec/javascripts" }
    watch(%r{^spec/javascripts/(.+)_spec\.(js\.coffee|js|coffee)$})
    watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)$}) { |m| "spec/javascripts/#{m[1]}_spec.#{m[2]}" }
  end
end

### Guard::Resque
#  available options:
#  - :task (defaults to 'resque:work' if :count is 1; 'resque:workers', otherwise)
#  - :verbose / :vverbose (set them to anything but false to activate their respective modes)
#  - :trace
#  - :queue (defaults to "*")
#  - :count (defaults to 1)
#  - :environment (corresponds to RAILS_ENV for the Resque worker)
guard 'resque', :environment => 'development' do
  watch(%r{^app/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})
end
