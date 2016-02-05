class UserAcquisition < ActiveRecord::Base
  attr_accessible :gclid, :landing_page, :referrer, :user_id, :utm_campaign, :utm_content, :utm_medium, :utm_source, :utm_term

  has_one :user
end
