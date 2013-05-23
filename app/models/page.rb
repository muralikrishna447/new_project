class Page < ActiveRecord::Base
  attr_accessible :title, :content

  friendly_id :title
  
  validates :title, presence: true
  validates :content, presence: true
end
