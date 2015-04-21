Intercom.app_id = "vy04t2n1"
Intercom.app_api_key = "149f294a76e91fecb7b66c6bed1889e64f487d07"

namespace :intercom do
  task :survey => :environment do
    User.where('id > ?', 194448).each do |user|
      # puts user.email
      interests = ''
      equipment = ''
      chef_type = ''
      begin
        puts "Getting results for user id: "
        puts user.id
        if user.survey_results
          user.survey_results.each do |result|
            if result['copy'] == "Which culinary topics interest you the most?"
              interests = result['answer']
            end
            if result['copy'] == "What equipment do you have in your kitchen?"
              equipment = result['answer']
            end
            if result['copy'] == "What kind of cook are you?"
              chef_type = result['answer']
            end
          end
        end
      rescue
        puts "Error getting survey results"
      end
      begin
        intercom_user = Intercom::User.find(:email => user.email)
        # puts intercom_user.inspect
        # puts "Interests: #{interests}"
        # puts "Equipment: #{equipment}"
        # puts "Chef Type: #{chef_type}"
        intercom_user.custom_attributes['interests'] = interests
        intercom_user.custom_attributes['equipment'] = equipment
        intercom_user.custom_attributes['chef_type'] = chef_type
        intercom_user.save
        puts "Updated Intercome user: #{intercom_user.inspect}"
      rescue
        puts "No intercom user found"
      end
    end
  end

  task :clean => :environment do
    next_page = true
    page = 1
    until next_page == nil
      inactive = Intercom::User.find(segment_id: '5526cc3fc2ec06b906000023', page: page)
      next_page = inactive.pages.next
      inactive.users.each do |inactive_user|
        # user.delete
        user_id = inactive_user["id"]
        user = Intercom::User.find(id: user_id).delete
        puts "User Deleted from Intercom: #{user.inspect}"
      end
      puts "*********** Page #{page} ************"
      page+=1
    end
  end

end