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

end
