class Activity < ActiveRecord::Base
  include RankedModel
  ranks :activity_order

  has_many :activity_equipment, inverse_of: :activity

  has_many :recipes, inverse_of: :activity
  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, through: :activity_equipment, inverse_of: :activities

  scope :ordered, rank(:activity_order)
  default_scope { ordered }

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty,
    :description, :equipment_ids, :recipe_ids, :step_ids,
    allow_destroy: true, as: :admin

  def difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def optional_equipment
    equipment.where(optional: true)
  end

  def required_equipment
    equipment.where(optional: false)
  end

  def next
    activities = Activity.all
    i = activities.index(self)
    activities[i+1]
  end

  def prev
    activities = Activity.all
    i = activities.index(self)
    return nil if i == 0
    activities[i-1]
  end

  def step_by_step?
    steps.count > 0
  end
end

