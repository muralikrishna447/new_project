# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(js|html)).*})  { |m| "/assets/#{m[2]}" }
  watch(%r{^(?:app|vendor)/assets/stylesheets/(?:([^/]+)/)?(?:.+/)*(.+?)\.(?:css\.)?s[ac]ss$}) { |m| "assets/#{m[1] || m[2]}.css" }
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

guard 'rspec', :cli => "--color --drb --fail-fast -f #{ENV['RSPEC_FORMAT'] || 'progress'}", :bundler => false do
  watch(%r{spec/(.*)_spec.rb})
  watch(%r{app/(.*)\.rb})                            { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{app/(.*\.haml)})                          { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{lib/(.*)\.rb})                            { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')                       { "spec" }
  watch('app/controllers/application_controller.rb') { "spec/controllers" }
end

guard 'spork' do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/routes.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
  watch('spec/spec_helper.rb')
  # devise caches user model
  #   watch('app/models/user.rb')
  #   end
  #
end
