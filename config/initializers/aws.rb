AWS.config( :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'] )

sns = OpenStruct.new
dynamodb = OpenStruct.new
Rails.configuration.sns = sns
Rails.configuration.dynamodb = dynamodb
sns.platform_applications = {}

Rails.configuration.dynamodb.transactional_email_log_table_name = "transactional-email-log-#{Rails.env}"
Rails.configuration.dynamodb.beta_features_table_name = "beta-features-#{Rails.env}"
Rails.configuration.dynamodb.shipping_address_table_name = "shipping-address-#{Rails.env}"

if Rails.env.production?
  Rails.configuration.remote_log_bucket = 'remote-logs-production'
  sns.platform_applications['android'] = 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android'
  sns.platform_applications['ios'] = 'arn:aws:sns:us-east-1:021963864089:app/APNS/joule-ios-prod'
else
  Rails.configuration.remote_log_bucket = 'remote-logs-staging'
  sns.platform_applications['android'] = 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android'
  sns.platform_applications['ios'] = 'arn:aws:sns:us-east-1:021963864089:app/APNS_SANDBOX/joule-ios-dev'
end
