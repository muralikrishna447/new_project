AWS.config( :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'] )

sns = OpenStruct.new
Rails.configuration.sns = sns
sns.platform_applications = {}

if Rails.env.production?
  Rails.configuration.remote_log_bucket = 'remote-logs-production'  
  
  # TODO - update to prod sns applications - not worried about forgetting since
  # we'll be forced to do this when app is released.
  sns.platform_applications['android'] = 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android'
  sns.platform_applications['ios'] = 'arn:aws:sns:us-east-1:021963864089:app/APNS_SANDBOX/joule-ios-dev'
else
  Rails.configuration.remote_log_bucket = 'remote-logs-staging'
  
  sns.platform_applications['android'] = 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android'
  sns.platform_applications['ios'] = 'arn:aws:sns:us-east-1:021963864089:app/APNS_SANDBOX/joule-ios-dev'
end
