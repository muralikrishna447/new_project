class Inclusion < ActiveRecord::Base
  include RankedModel

  ranks :activity_order, :with_same => :course_id
  default_scope include: :activity
  scope :ordered, rank(:activity_order)
  belongs_to :course
  belongs_to :activity

  has_many :events, as: :trackable, dependent: :destroy

  attr_accessible :course, :activity, :activity_order, :nesting_level, :title

  def syllabus_title
    title || activity.title
  end
end
