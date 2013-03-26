task :move_images_to_filepicker => :environment do
  require "#{Rails.root}/app/helpers/application_helper"
  include ApplicationHelper

  def move_image(obj, prop)
    old_id = obj.send(prop.to_s)
    if old_id != nil && old_id != ''
      if old_id.starts_with?("http")
        puts "Already converted: #{old_id}"
      else
        puts "Converting: #{old_id}"
        begin
          RestClient.post 'https://www.filepicker.io/api/store/S3',
                             {url: s3_image_url(old_id)},
                             content_type: "application/x-www-form-urlencoded",
                             params: {key: ::Rails.application.config.filepicker_rails.api_key} do |response|

            new_url = JSON.parse(response)["url"]
            if new_url == nil || new_url == ''
              puts 'Conversion failed. Response: #{response}'
            else
              obj.send((prop + "=").to_s, new_url)
              obj.save!
              puts "Updated to #{new_url}"
            end
          end
        rescue
          puts 'Ignoring exception!'
        end
      end
    end
  end

  Activity.all.each do |act|
    move_image(act, "image_id")
    move_image(act, "featured_image_id")
  end

  Step.all.each do |step|
    move_image(step, "image_id")
  end
end