class Activity < ActiveRecord::Base

  has_many :recipes, inverse_of: :activity
  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity, dependent: :destroy

  accepts_nested_attributes_for :steps, :equipment, :recipes

  scope :ordered, order("activity_order")
  default_scope { ordered }

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty, :activity_order,
    :description, :equipment_ids, :recipe_ids, :step_ids,
    allow_destroy: true, as: :admin

  def self.difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def optional_equipment
    equipment.optional
  end

  def required_equipment
    equipment.required
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

  def has_description?
    description.present?
  end

  def step_by_step?
    steps.count > 0
  end

end

