class Poll < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  
  attr_accessible :description, :slug, :status, :title, :image_id, :poll_items_attributes
  has_many :poll_items

  accepts_nested_attributes_for :poll_items

  after_save :check_status

  def winner
    poll_items.order('poll_items.votes_count desc')
  end

  private

  def check_status
    if self.status == 'Closed' && self.closed_at.blank?
      self.closed_at = DateTime.now
      self.save
    end
  end
end
