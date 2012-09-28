task :after_deploy do
  each_heroku_app do |stage|
    revision = stage.revision.split.first
    stage.push_config('REVISION' => revision) if revision
  end
end
