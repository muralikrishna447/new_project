class Activity < ActiveRecord::Base
  include RankedModel
  ranks :activity_order

  has_many :activity_equipment

  has_many :recipes
  has_many :steps, dependent: :destroy
  has_many :equipment, through: :activity_equipment
  has_many :ingredients, through: :recipes

  scope :ordered, rank(:activity_order)
  default_scope { ordered }

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty, as: :admin

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

  def overview?
    equipment.any? || ingredients.any? || description.present?
  end

  def step_by_step?
    steps.count > 0
  end
end

