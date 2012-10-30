class Equipment < ActiveRecord::Base
  has_many :activity_equipment, inverse_of: :equipment
  has_many :activities, through: :activity_equipment, inverse_of: :equipment

  attr_accessible :title, :product_url

  def self.titles
    all.map(&:title)
  end

end

