task teamcity: ['teamcity:setup', 'teamcity:spec']

namespace :teamcity do
  task :setup do
    RAILS_ENV = 'test'
    Rake::Task['db:setup'].invoke
    Rake::Task['db:test:prepare'].invoke
  end

  task :spec do
    RAILS_ENV = 'test'
    Rake::Task['spec'].prerequisites.clear
    Rake::Task['spec'].invoke
  end
end
