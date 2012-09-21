class Activity < ActiveRecord::Base
  include RankedModel
  ranks :activity_order

  has_many :recipes, dependent: :destroy, inverse_of: :activity
  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity

  scope :ordered, rank(:activity_order)
  default_scope { ordered }

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty,
    :description, :equipment_ids, :recipe_ids, :step_ids,
    allow_destroy: true, as: :admin

  def difficulty_enum
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

  def step_by_step?
    steps.count > 0
  end

  def recipe_ids=(ids)
    unless (ids = ids.map(&:to_i).select { |i| i>0 }) == (current_ids = recipes.map(&:id))
      ids.each_with_index do |id, index|
        if current_ids.include? (id)
          recipes.select { |b| b.id == id }.first.update_attribute(:recipe_order_position, (index+1))
        else
          raise "Can't add Recipe: #{id}"
        end
      end
      (current_ids - ids).each { |id| recipes.select{|b|b.id == id}.first.update_attribute(:activity_id, nil)}
    end
  end

end

