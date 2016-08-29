class Advertisement < ActiveRecord::Base
  include PublishableModel
  attr_accessible :published, :image, :title, :description, :button_title, :url, :campaign
end
