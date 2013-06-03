class Upload < ActiveRecord::Base
  attr_accessible :activity_id, :image_id, :notes, :recipe_name, :user_id, :course_id, :approved
  belongs_to :course
  belongs_to :activity
  belongs_to :user

  has_many :likes, as: :likeable

  scope :approved, where(approved: true)
  scope :unnapproved, where(approved: false)
end
