class PushNotificationToken < ActiveRecord::Base
  # states

  belongs_to :actor_address

  validates :app_name, length: { minimum: 2, maximum: 20 }
  validates :endpoint_arn, length: { minimum: 10, maximum: 255 }
  validates :device_token, length: { minimum: 2 }
  validates_uniqueness_of :endpoint_arn
  validates_uniqueness_of :actor_address_id

  def self.platform_application_arn(platform, app_name)
    platform_applications = Rails.configuration.sns.platform_applications_by_app_name[app_name]
    return (platform_applications || {})[platform]
  end
end
