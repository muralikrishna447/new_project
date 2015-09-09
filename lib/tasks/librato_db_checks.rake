
namespace :librato do
  task :new_users => :environment do
    end_time = Time.now
    delta = 1.day
    start_time = end_time - delta
    user_count = User.where(created_at: (start_time..end_time)).count
    puts "#{user_count} new users between #{start_time} and #{end_time}"
    Librato.measure 'user.signup.trailing-day', user_count
  end
end
