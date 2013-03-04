class Ingredient < ActiveRecord::Base
  include CaseInsensitiveTitle

  has_many :step_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activity_ingredients, dependent: :destroy, inverse_of: :ingredient
  has_many :activities, through: :activity_ingredients, inverse_of: :ingredients
  has_many :steps, through: :step_ingredients, inverse_of: :ingredients

  attr_accessible :title, :product_url, :for_sale

  # This is for activities that are used as an ingredient in higher level recipes.
  # Note the potential for confusion: the has_many activities is for activities
  # that use this ingredient. The sub_activity_id is for ingredients that *are*
  # a (nested) activity - which will also typically be used in some activity.
  attr_accessible :sub_activity_id

  before_save :get_title_from_subactivity
  def get_title_from_subactivity
    if self.sub_activity_id?
      self.title= Activity.find_by_id(self.sub_activity_id).title
    end
  end

  def title
    if sub_activity_id?
      act = Activity.find_by_id(sub_activity_id)
      if act != nil
        return act.title
      end
    end
    read_attribute(:title)
  end

  def self.titles
    all.map(&:title)
  end

  def self.find_or_create_by_subactivity_or_ingredient_title(title)
    sub_act = Activity.find_by_title(title)
    if sub_act != nil
      return find_or_create_by_sub_activity_id(sub_act.id)
    end
    find_or_create_by_title(title)
  end
end

