class Ingredient < ActiveRecord::Base
  include CaseInsensitiveTitle

  has_many :step_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activity_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activities, through: :activity_ingredients, inverse_of: :ingredients
  has_many :steps, through: :step_ingredients, inverse_of: :ingredients

  validates :title, presence: true

  attr_accessible :title, :product_url, :for_sale

  def self.titles
    all.map(&:title)
  end
end

