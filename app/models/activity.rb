class Activity < ActiveRecord::Base
  extend FriendlyId
  include RankedModel

  friendly_id :title, use: :slugged

  ranks :activity_order

  has_many :steps, inverse_of: :activity, dependent: :destroy
  has_many :equipment, class_name: ActivityEquipment, inverse_of: :activity, dependent: :destroy

  has_many :activity_recipes, class_name: ActivityRecipe, inverse_of: :activity, dependent: :destroy
  has_many :recipes, through: :activity_recipes, inverse_of: :activities

  has_many :recipe_steps, class_name: ActivityRecipeStep, inverse_of: :activity , dependent: :destroy

  has_many :quizzes

  accepts_nested_attributes_for :steps, :equipment, :recipes

  scope :ordered, rank(:activity_order)
  scope :published, where(published: true)

  attr_accessible :title, :youtube_id, :yield, :timing, :difficulty, :activity_order, :description, :equipment, :published

  def self.difficulty_enum
    ['easy', 'intermediate', 'advanced']
  end

  def self.find_published(id, token=nil)
    scope = PrivateToken.valid?(token) ? scoped : published
    scope.find(id)
  end

  def optional_equipment
    equipment.optional.ordered
  end

  def required_equipment
    equipment.required.ordered
  end

  def next
    activities = Activity.ordered.published.all
    i = activities.index(self)
    return nil if i.nil?
    activities[i+1]
  end

  def prev
    activities = Activity.ordered.published.all
    i = activities.index(self)
    return nil if i.nil? || i == 0
    activities[i-1]
  end

  def has_description?
    description.present?
  end

  def has_recipes?
    recipes.present?
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
    update_recipe_steps(recipe_ids)
    self
  end

  def update_steps(step_attrs)
    reject_invalid_steps(step_attrs)
    update_and_create_steps(step_attrs)
    delete_old_steps(step_attrs)
    self
  end

  def update_recipe_steps(recipe_ids = nil)
    recipe_ids ||= recipes.map(&:id)
    create_activity_recipe_steps(recipe_ids)
    delete_old_activity_recipe_steps(recipe_ids)
    self
  end

  def has_ingredients?
    recipes.any?(&:has_ingredients?)
  end

  def ordered_recipes
    activity_recipes.ordered.all.map(&:recipe)
  end

  def ordered_recipe_steps
    recipe_steps.ordered.all
  end

  def ordered_steps
    steps.ordered.activity_id_not_nil.all
  end

  def update_recipe_step_order(recipe_step_ids)
    recipe_step_ids.select!(&:present?)
    recipe_step_ids.each do |recipe_step_id|
      recipe_steps.find(recipe_step_id).update_attributes(step_order_position: :last)
    end
  end

  private

  def update_recipe_associations(recipe_ids)
    recipe_ids.each do |recipe_id|
      recipes << Recipe.find(recipe_id) unless recipes.exists?(recipe_id)
      activity_recipes.find_by_recipe_id(recipe_id).update_attributes(recipe_order_position: :last)
    end
  end

  def create_activity_recipe_steps(recipe_ids)
    recipe_step_ids = Step.joins(:recipe).where(recipe_id: recipe_ids).map(&:id)
    recipe_step_ids.each do |step_id|
      recipe_steps.find_or_create_by_step_id_and_activity_id(step_id, self.id)
    end
  end

  def delete_old_activity_recipe_steps(recipe_ids)
    current_step_ids = recipe_steps.map(&:step_id)
    recipe_step_ids = Step.joins(:recipe).where(recipe_id: recipe_ids).map(&:id)
    old_step_ids = current_step_ids - recipe_step_ids
    recipe_steps.where(step_id: old_step_ids).destroy_all
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

  def reject_invalid_steps(step_attrs)
    step_attrs.select! do |step_attr|
      [:directions].all? do |test|
        step_attr[test].present?
      end
    end
  end

  def update_and_create_steps(step_attrs)
    step_attrs.each do |step_attr|
      step = steps.find_or_create_by_id(step_attr[:id])
      step.update_attributes(
        title: step_attr[:title],
        directions: step_attr[:directions],
        youtube_id: step_attr[:youtube_id],
        image_id: step_attr[:image_id],
        step_order_position: :last
      )
      step_attr[:id] = step.id
    end
  end

  def delete_old_steps(step_attrs)
    old_step_ids = steps.map(&:id) - step_attrs.map {|i| i[:id].to_i }
    steps.where(id: old_step_ids).destroy_all
  end
end

