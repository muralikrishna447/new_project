class PushNotificationToken < ActiveRecord::Base
  # states

  belongs_to :actor_address
  attr_accessible :app_name, :endpoint_arn, :actor_address_id, :device_token
  
  validates :app_name, length: { minimum: 2, maximum: 20 }
  validates :endpoint_arn, length: { minimum: 10, maximum: 255 }
  validates :device_token, length: { minimum: 2 }
  validates_uniqueness_of :endpoint_arn
  validates_uniqueness_of :actor_address_id
  
  def self.platform_application_arn(platform)
    Rails.configuration.sns.platform_applications[platform]
  end
end
