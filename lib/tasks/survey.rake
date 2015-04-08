namespace :survey do
  task :intercom => :environment do
    Intercom.app_id = "vy04t2n1"
    Intercom.app_api_key = "149f294a76e91fecb7b66c6bed1889e64f487d07"
    User.find_each do |user|
      puts user.email
      begin
        intercom_user = Intercom::User.find(:email => user.email)
        puts intercom_user
      rescue
        puts "No intercom user found"
      end
    end
  end
end