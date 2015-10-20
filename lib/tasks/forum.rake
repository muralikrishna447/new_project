namespace :forum do
  namespace :users do
    task :update => :environment do
      puts 'Updating Forum Users'
      users = User.where('id > ?', 300000)
      users.each do |user|
        puts "user id: #{user.id}"
        HTTParty.get "https://cs-bloom-api-production.herokuapp.com/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
      end
    end
  end
end
