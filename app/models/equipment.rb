class Equipment < ActiveRecord::Base
  has_many :activities, :through => :activity_equipment

  attr_accessible :title, :product_url, :activity_id, as: :admin

  def product_url?
    product_url.present?
  end
end

