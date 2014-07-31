class Upload < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :activity_id, :image_id, :notes, :title, :user_id, :course_id, :assembly_id, :approved
  belongs_to :activity
  belongs_to :user
  belongs_to :assembly

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :events, as: :trackable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  scope :approved, where(approved: true)
  scope :unapproved, where(approved: false)

  def featured_image
    image_id
  end

  def uploadable
    if activity
      activity
    elsif assembly
      assembly
    end
        
  end

  def parent_title
    if activity
      activity.title
    elsif assembly
      assembly.title
    end
  end
end
