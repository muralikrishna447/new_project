class Upload < ActiveRecord::Base
  attr_accessible :activity_id, :image_id, :notes, :recipe_name, :user_id
  belongs_to :activity
  belongs_to :user
end
