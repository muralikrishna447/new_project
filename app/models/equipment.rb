class Equipment < ActiveRecord::Base
  has_many :activities, through: :activity_equipment

  attr_accessible :title, :product_url, :optional, as: :admin


  scope :optional, where(optional: true)

  def product_url?
    product_url.present?
  end
end

