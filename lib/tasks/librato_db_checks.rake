require 'librato/metrics'

namespace :librato do
  task :new_users, [:should_submit] => :environment do |t, args|
    end_time = Time.now
    delta = 1.day
    start_time = end_time - delta
    user_count = User.where(created_at: (start_time..end_time)).count
    puts "#{user_count} new users between #{start_time} and #{end_time}"
    if args[:should_submit]
      puts "Actually posting to Librato"
      Librato::Metrics.authenticate(
        ENV['LIBRATO_USER'],
        ENV['LIBRATO_TOKEN']
      )
      Librato::Metrics.submit 'user.signup.trailing-day' => user_count
    end
  end
end
