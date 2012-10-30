class Ingredient < ActiveRecord::Base
  before_save :capitalize_title

  has_many :step_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :recipe_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :recipes, through: :recipe_ingredients, inverse_of: :ingredients
  has_many :steps, through: :step_ingredients, inverse_of: :ingredients

  validates :title, presence: true

  attr_accessible :title, :product_url, :for_sale

  def self.titles
    all.map(&:title)
  end

  private

  def capitalize_title
    self.title = title.capitalize
  end

end

