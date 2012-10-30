task teamcity: ['teamcity:setup', 'teamcity:spec']

namespace :teamcity do
  task :setup do
    RAILS_ENV = 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
  end

  task :spec do
    RAILS_ENV = 'test'
    Rake::Task['spec'].preqrequisites.clear
    Rake::Task['spec'].invoke
  end
end
