CS_UNICORN_WORKER_COUNT = (ENV.fetch('CS_UNICORN_WORKER_COUNT', 3).to_i || 3) # amount of unicorn workers to spin up

puts "CS_UNICORN_WORKER_COUNT=#{CS_UNICORN_WORKER_COUNT}"

worker_processes CS_UNICORN_WORKER_COUNT
timeout 35         # restarts workers that hang for 35 seconds, 5 seconds longer than heroku timeout

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  puts "Unicorn before_fork nr=#{worker.nr}"

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  puts "Unicorn after_fork nr=#{worker.nr}"

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

backlog_setting = Integer(ENV['CS_UNICORN_BACKLOG'] || 1024) # Current CS using default

puts "Unicorn PORT=#{ENV['PORT']} CS_UNICORN_BACKLOG=#{backlog_setting}"

listen ENV['PORT'], :backlog => backlog_setting
