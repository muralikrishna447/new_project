require 'fileutils'

task :copy_production_db do
  username =  ENV['LOGNAME']
  username_dev = username + "_development"
  sh %{heroku pgbackups:capture --expire --remote production --app production-chefsteps}
  sh %{curl -o /tmp/latest.dump `heroku pgbackups:url --remote production --app production-chefsteps`}
  sh %{pg_restore --verbose --clean --no-acl --no-owner -h localhost -U #{username} -d delve_development /tmp/latest.dump} do |ok, res|
    # pg_restore often has minor errors we have to ignore
  end
  sh %{rm /tmp/latest.dump}
  sh %{psql -d #{username_dev}  -U #{username} -c "ALTER USER delve WITH SUPERUSER;"}
end