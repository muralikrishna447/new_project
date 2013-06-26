task :update_likes_count => :environment do
  uploads = Upload.all
  uploads.each do |upload|
    upload.likes_count = upload.likes.count
    if upload.save
      puts "Updated likes count for Upload:"
      puts upload.inspect
    else
      puts "ERROR UPDATING LIKE COUNT FOR:"
      puts upload.inspect
    end
  end
end