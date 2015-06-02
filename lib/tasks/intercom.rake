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

  task :import, [:start_id] => :environment do |t, args|
    start_id = args[:start_id]
    User.order('id asc').where('id > ?', start_id).each do |user|
      begin
        intercom_user = Intercom::User.find(:email => user.email)
        puts "intercom user found: #{user.email}"
        puts "user id: #{user.id}"
        puts '*'*20
      rescue
        puts "No intercom user found"
        puts "Importing user with id:"
        puts user.id
        paid_classes = user.enrollments.where('price > 0')
        paid_classes_count = paid_classes.blank? ? "0" : paid_classes.count.to_s

        free_classes = user.enrollments.where(price: 0)
        free_classes_count = free_classes.blank? ? "0" : free_classes.count.to_s

        uploads = user.uploads
        uploads_count = uploads.blank? ? "0" : uploads.count.to_s

        recipes_created = user.created_activities
        recipes_created_count = recipes_created.blank? ? "0" : recipes_created.count.to_s

        recipes_published = user.created_activities.published
        recipes_published_count = recipes_published.blank? ? "0" : recipes_published.count.to_s

        begin
          puts "Getting results for user id: "
          puts user.id
          interests = nil
          equipment = nil
          chef_type = nil
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

        data = {
          name: user.name,
          email: user.email,
          signed_up_at: user.created_at.to_time.to_i
        }

        intercom_user = Intercom::User.create(data)
        puts "created intercom user: "
        puts intercom_user.email

        custom_attributes = {
          user_id: user.id,
          paid_classes: paid_classes_count,
          free_classes: free_classes_count,
          uploads: uploads_count,
          recipes_created: recipes_created_count,
          recipes_published: recipes_published_count,
          interests: interests.blank? ? '': interests,
          equipment: equipment.blank? ? '' : equipment,
          chef_type: chef_type.blank? ? '' : chef_type
        }

        puts "custom_attributes: ", custom_attributes
        custom_attributes.each do |key, value|
          intercom_user.custom_attributes[key] = value
        end

        intercom_user.save
        puts 'updated intercome user key values: '
        puts intercom_user.email

        puts '*'*20
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