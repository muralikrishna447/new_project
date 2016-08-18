class Advertisement < ActiveRecord::Base
  attr_accessible :image, :title, :description, :button_title, :url, :campaign
end
