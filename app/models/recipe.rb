class Recipe < ActiveRecord::Base
  include RankedModel
  ranks :recipe_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :recipes
  has_many :ingredients, dependent: :destroy, class_name: RecipeIngredient, inverse_of: :recipe
  has_many :steps, dependent: :destroy, inverse_of: :recipe

  validates :title, presence: true

  attr_accessible :title, :activity_id, :yield, :step_ids, :ingredients, allow_destroy: true

  accepts_nested_attributes_for :ingredients, :steps

  scope :ordered, rank(:recipe_order)

  default_scope { ordered }

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

  def reject_invalid_steps(step_attrs)
    step_attrs.select! do |step_attr|
      [:title, :directions].all? do |test|
        step_attr[test].present?
      end
    end
  end

  def update_and_create_ingredients(ingredient_attrs)
    ingredient_attrs.each do |ingredient_attr|
      ingredient = Ingredient.find_or_create_by_title(ingredient_attr[:title])
      recipe_ingredient = ingredients.find_or_create_by_ingredient_id_and_recipe_id(ingredient.id, self.id)
      recipe_ingredient.update_attributes(quantity: ingredient_attr[:quantity], unit: ingredient_attr[:unit])
    end
  end

  def update_and_create_steps(step_attrs)
    step_attrs.each do |step_attr|
      step = steps.find_or_create_by_title_and_recipe_id(step_attr[:title], self.id)
      step.update_attributes(
                             title: step_attr[:title],
                             directions: step_attr[:directions],
                             youtube_id: step_attr[:youtube_id],
                             image_id: step_attr[:image_id]
                            )
    end
  end

  def delete_old_ingredients(ingredient_attrs)
    old_ingredient_titles = ingredients.map(&:title) - ingredient_attrs.map {|i| i[:title] }
    ingredients.joins(:ingredient).where('ingredients.title' => old_ingredient_titles).destroy_all
  end

  def delete_old_steps(step_attrs)
    old_step_titles = steps.map(&:title) - step_attrs.map {|i| i[:title] }
    steps.where(title: old_step_titles).destroy_all
  end
end

