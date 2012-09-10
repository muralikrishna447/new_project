class ActivityIngredient < ActiveRecord::Base
  belongs_to :activity
  belongs_to :ingredient

  attr_accessible :activity_id, :ingredient_id, as: :admin
end

