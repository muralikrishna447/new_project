class Upload < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :activity
  belongs_to :user
  belongs_to :assembly

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :events, as: :trackable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where(approved: false) }

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

  def parent
    if activity
      activity
    elsif assembly
      assembly
    end

  end
end
