class Recipe < ActiveRecord::Base
  belongs_to :activity, touch: true

  attr_accessible :title, :activity_id, as: :admin

end

