class Activity < ActiveRecord::Base

  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity, dependent: :destroy

  has_many :activity_recipes, class_name: ActivityRecipe, inverse_of: :activity, dependent: :destroy
  has_many :recipes, through: :activity_recipes, inverse_of: :activities

  accepts_nested_attributes_for :steps, :equipment, :recipes

  scope :ordered, order("activity_order")
  default_scope { ordered }

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty, :activity_order, :description, :equipment

  def self.difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def optional_equipment
    equipment.optional.ordered
  end

  def required_equipment
    equipment.required.ordered
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

  def update_equipment(equipment_attrs)
    reject_invalid_equipment(equipment_attrs)
    update_and_create_equipment(equipment_attrs)
    delete_old_equipment(equipment_attrs)
    self
  end

  def update_recipes(recipe_ids)
    reject_invalid_recipe_ids(recipe_ids)
    update_recipe_associations(recipe_ids)
    delete_old_recipes(recipe_ids)
    self
  end

  def has_ingredients?
    recipes.any?(&:has_ingredients?)
  end

  def ordered_recipes
    activity_recipes.ordered.all.map(&:recipe)
  end

  private

  def update_recipe_associations(recipe_ids)
    recipe_ids.each do |recipe_id|
      recipes << Recipe.find(recipe_id) unless recipes.exists?(recipe_id)
      activity_recipes.find_by_recipe_id(recipe_id).update_attributes(recipe_order_position: :last)
    end
  end

  def reject_invalid_recipe_ids(recipe_ids)
    recipe_ids.select! do |recipe_id|
      recipe_id.present?
    end
  end

  def delete_old_recipes(recipe_ids)
    old_recipe_ids = recipes.map(&:id) - recipe_ids.map(&:to_i)
    activity_recipes.where(recipe_id: old_recipe_ids).destroy_all
  end

  def reject_invalid_equipment(equipment_attrs)
    equipment_attrs.select! do |equipment_attr|
      [:title].all? do |test|
        equipment_attr[test].present?
      end
    end
  end

  def update_and_create_equipment(equipment_attrs)
    equipment_attrs.each do |equipment_attr|
      equipment_item = Equipment.find_or_create_by_title(equipment_attr[:title])
      equipment_item.update_attributes(product_url: equipment_attr[:product_url])
      activity_equipment = equipment.find_or_create_by_equipment_id_and_activity_id(equipment_item.id, self.id)
      activity_equipment.update_attributes(
        optional: equipment_attr[:optional] || false,
        equipment_order_position: :last
      )
      equipment_attr[:id] = equipment_item.id
    end
  end

  def delete_old_equipment(equipment_attrs)
    old_equipment_ids = equipment.map(&:equipment_id) - equipment_attrs.map {|i| i[:id].to_i }
    equipment.where(equipment_id: old_equipment_ids).destroy_all
  end

end

