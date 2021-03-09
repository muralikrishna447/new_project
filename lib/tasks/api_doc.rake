namespace :api_doc do
  desc 'Generate API documentation markdown'

  task :json, [:version, :docs_path] => :environment do |_, args|
    require 'rspec/core/rake_task'
    version = args[:version] || :v0

    RSpec::Core::RakeTask.new(:api_spec) do |t|
      t.pattern = "spec/controllers/api/#{version}/"
      t.rspec_opts = "-f Dox::Formatter --order defined --tag dox --out spec/docs/#{version}/schema/apispec.json"
    end

    Rake::Task['api_spec'].invoke
  end

  task :html, [:version, :docs_path] => :json do |_, args|
    version = args[:version] || :v0
    docs_path = args[:docs_path] || "api/#{version}/docs"

    `npx redoc-cli bundle -o public/#{docs_path}/index.html spec/docs/#{version}/schema/apispec.json`
  end

  task :generate, [:version, :docs_path] => :html do |_, args|
  end
end
