task :backup_bloom => :environment do

  # Get data from endpoint
  url = "http://apiv2.usebloom.com/utils/backup?apiKey=xchefsteps&secret=xchefstepscRP9pJomgiluvfoodNTJto"
  response = HTTParty.get url
  data = response.body

  # Config S3
  # Documentation: http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html
  s3 = AWS::S3.new(
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])

  # Create name and s3object.  Upload to the 'chefsteps' bucket and into the bloom-backups folder
  datetime = DateTime.now.to_s(:number)
  name = "bloom-backups/bloom-backup-#{datetime}.json"
  obj = s3.buckets['chefsteps'].objects[name]

  # Write to s3object
  obj.write(data)

end

task :check_bloom_data => :environment do
  s3 = AWS::S3.new(
    :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])

  keys = []
  bucket = s3.buckets['chefsteps']
  bucket.objects.with_prefix('bloom-backups/bloom-backup-').each do |obj|
    keys << obj.key
  end

  # Get the last file in the folder
  obj = s3.buckets['chefsteps'].objects[keys.last]

  file = obj.read
  data = JSON.parse file

  puts "Posts Count: "
  puts data["posts"].count
  puts "Comments Count: "
  puts data["comments"].count
end