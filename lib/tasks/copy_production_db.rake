require 'fileutils'

task :copy_production_db do
  # username =  'hueezer'
  # username_dev = username + "_development"
  sh %{heroku pg:backups:capture --app production-chefsteps}
  sh %{curl -o /tmp/latest.dump `heroku pg:backups:public-url --app production-chefsteps`}
  sh %{pg_restore --verbose --clean --no-acl --no-owner -h localhost -U delve -d delve_development /tmp/latest.dump} do |ok, res|
    # pg_restore often has minor errors we have to ignore
  end
  sh %{rm /tmp/latest.dump}
  sh %{psql -d delve_development  -U delve -c "ALTER USER delve WITH SUPERUSER;"}
end
