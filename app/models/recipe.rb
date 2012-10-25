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
    ingredient_attrs.map do |ingredient_attr|
      ingredient = Ingredient.find_or_create_by_title(ingredient_attr.delete(:title))
      recipe_ingredient = ingredients.find_or_create_by_ingredient_id_and_recipe_id(ingredient.id, self.id)
      recipe_ingredient.update_attributes(ingredient_attr)
    end
    self
  end

end

