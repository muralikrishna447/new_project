class Inclusion < ActiveRecord::Base
  include RankedModel

  ranks :activity_order, :with_same => :course_id

  scope :ordered, rank(:activity_order)
  belongs_to :course
  belongs_to :activity

  attr_accessible :course, :activity, :activity_order, :nesting_level
end
