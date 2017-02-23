class Advertisement < ActiveRecord::Base
  include PublishableModel
  attr_accessible :matchname, :published, :image, :title, :description, :button_title, :url, :campaign, :weight, :add_referral_code
end