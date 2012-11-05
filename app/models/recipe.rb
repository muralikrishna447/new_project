class Recipe < ActiveRecord::Base
  has_many :activity_recipes, inverse_of: :recipe
  has_many :activities, through: :activity_recipes, inverse_of: :recipes

  has_many :ingredients, dependent: :destroy, class_name: RecipeIngredient, inverse_of: :recipe
  has_many :steps, dependent: :destroy, inverse_of: :recipe

  validates :title, presence: true

  attr_accessible :title, :yield, :steps, :ingredients

  accepts_nested_attributes_for :ingredients, :steps

  def has_ingredients?
    !ingredients.empty?
  end

  def update_ingredients(ingredient_attrs)
    reject_invalid_ingredients(ingredient_attrs)
    update_and_create_ingredients(ingredient_attrs)
    delete_old_ingredients(ingredient_attrs)
    self
  end

  def update_steps(step_attrs)
    reject_invalid_steps(step_attrs)
    update_and_create_steps(step_attrs)
    delete_old_steps(step_attrs)
    update_activity_recipe_steps
    self
  end

  private

  def reject_invalid_ingredients(ingredient_attrs)
    ingredient_attrs.select! do |ingredient_attr|
      [:title, :quantity, :unit].all? do |test|
        ingredient_attr[test].present?
      end
    end
  end

  def update_activity_recipe_steps
    activities.each(&:update_recipe_steps)
  end

  def reject_invalid_steps(step_attrs)
    step_attrs.select! do |step_attr|
      [:directions].all? do |test|
        step_attr[test].present?
      end
    end
  end

  def update_and_create_ingredients(ingredient_attrs)
    ingredient_attrs.each do |ingredient_attr|
      ingredient = Ingredient.find_or_create_by_title(ingredient_attr[:title])
      recipe_ingredient = ingredients.find_or_create_by_ingredient_id_and_recipe_id(ingredient.id, self.id)
      recipe_ingredient.update_attributes(
        quantity: ingredient_attr[:quantity],
        unit: ingredient_attr[:unit],
        ingredient_order_position: :last
      )
      ingredient_attr[:id] = ingredient.id
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

  def delete_old_ingredients(ingredient_attrs)
    old_ingredient_ids = ingredients.map(&:ingredient_id) - ingredient_attrs.map {|i| i[:id].to_i }
    ingredients.where(ingredient_id: old_ingredient_ids).destroy_all
  end

  def delete_old_steps(step_attrs)
    old_step_ids = steps.map(&:id) - step_attrs.map {|i| i[:id].to_i }
    steps.where(id: old_step_ids).destroy_all
  end
end

