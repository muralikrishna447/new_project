class Equipment < ActiveRecord::Base
  has_many :activity_equipment
  has_many :activities, through: :activity_equipment

  attr_accessible :title, :product_url, :optional, as: :admin


  scope :optional, where(optional: true)

end

