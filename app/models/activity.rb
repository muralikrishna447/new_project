class Activity < ActiveRecord::Base
  has_many :activity_ingredients
  has_many :activity_equipment

  has_many :steps, dependent: :destroy
  has_many :equipment, through: :activity_equipment
  has_many :ingredients, class_name: ActivityIngredient

  attr_accessible :title, :video_url, as: :admin

  def video?
    video_url.present?
  end

  def optional_equipment
    equipment.where(optional: true)
  end

  def required_equipment
    equipment.where(optional: false)
  end

end

