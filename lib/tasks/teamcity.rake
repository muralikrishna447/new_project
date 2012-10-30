namespace :teamcity do
  task :setup do
    system('bundle exec rake db:drop db:create db:schema:load RAILS_ENV=test')
  end
end

task teamcity: ["teamcity:setup", :spec]
