AWS.config( :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'] )

sns = OpenStruct.new
dynamodb = OpenStruct.new
Rails.configuration.sns = sns
Rails.configuration.dynamodb = dynamodb

Rails.configuration.dynamodb.transactional_email_log_table_name = "transactional-email-log-#{Rails.env}"
Rails.configuration.dynamodb.beta_features_table_config = {
  :features_table => "beta-feature-info-#{Rails.env}",
  :group_features_table => "beta-feature-group-features-#{Rails.env}",
  :group_associations_table => "beta-feature-group-associations-#{Rails.env}",
}
Rails.configuration.dynamodb.shipping_address_update_table_name = "shipping-address-updates-#{Rails.env}"
Rails.configuration.dynamodb.shipping_address_confirmation_table_name = "shipping-address-confirmations-#{Rails.env}"

Rails.configuration.dynamodb.push_notifications_table = "push-notifications-#{Rails.env}"

if Rails.env.production?
  Rails.configuration.remote_log_bucket = 'remote-logs-production'
  sns.platform_applications_by_app_name = {
    'joule' => {
      'android' => 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android',
      'ios' => 'arn:aws:sns:us-east-1:021963864089:app/APNS/joule-ios-prod',
    },
    'joule-beta' => {
      'android' => 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-beta-android',
      'ios' => 'arn:aws:sns:us-east-1:021963864089:app/APNS/joule-beta-ios-prod',
    }
  }
else
  Rails.configuration.remote_log_bucket = 'remote-logs-staging'
  sns.platform_applications_by_app_name = {
    'joule' => {
      'android' => 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-android',
      'ios' => 'arn:aws:sns:us-east-1:021963864089:app/APNS_SANDBOX/joule-ios-dev',
    },
    'joule-beta' => {
      'android' => 'arn:aws:sns:us-east-1:021963864089:app/GCM/joule-beta-android',
      'ios' => 'arn:aws:sns:us-east-1:021963864089:app/APNS_SANDBOX/joule-beta-ios-dev',
    }
  }
end
