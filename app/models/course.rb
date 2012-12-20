class Course < ActiveRecord::Base
  extend FriendlyId
  include RankedModel
  include PublishableModel

  friendly_id :title, use: :slugged

  ranks :course_order

  scope :ordered, rank(:course_order)

  attr_accessible :description, :title, :slug, :course_order

  has_many :inclusions
  has_many :activities, :through => :inclusions, :order => 'inclusions.activity_order ASC'

  def update_activities(activity_ids)
    activities.delete_all
    activity_ids.each do |activity_id|
      activity = Activity.find(activity_id)
      if activity
        self.activities << activity
        self.save!
      end
    end
    self
  end

end
