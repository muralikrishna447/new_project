class Recipe < ActiveRecord::Base
  include RankedModel
  ranks :recipe_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :recipes
  has_many :ingredients, class_name: RecipeIngredient, inverse_of: :recipe
  has_many :steps, dependent: :destroy, inverse_of: :recipe

  validates :title, presence: true

  attr_accessible :title, :activity_id, :yield, :step_ids, :ingredient_ids,
    allow_destroy: true, as: :admin

  scope :ordered, rank(:recipe_order)

  default_scope { ordered }

  def ingredient_ids=(ids)
    unless (ids = ids.map(&:to_i).select { |i| i>0 }) == (current_ids = ingredients.map(&:id))
      ids.each_with_index do |id, index|
        if current_ids.include? (id)
          ingredients.select { |b| b.id == id }.first.update_attribute(:ingredient_order_position, (index+1))
        else
          raise "Can't add Ingredient: #{id}"
        end
      end
      (current_ids - ids).each { |id| ingredients.select{|b|b.id == id}.first.destroy}
    end
  end

  def step_ids=(ids)
    unless (ids = ids.map(&:to_i).select { |i| i>0 }) == (current_ids = steps.map(&:id))
      ids.each_with_index do |id, index|
        if current_ids.include? (id)
          steps.select { |b| b.id == id }.first.update_attribute(:step_order_position, (index+1))
        else
          raise "Can't add Step: #{id}"
        end
      end
      (current_ids - ids).each { |id| steps.select{|b|b.id == id}.first.destroy}
    end
  end
end

