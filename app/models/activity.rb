class Activity < ActiveRecord::Base
  include ApplicationHelper
  has_many :activity_ingredients
  has_many :activity_equipment

  has_many :steps, dependent: :destroy
  has_many :equipment, through: :activity_equipment
  has_many :ingredients, class_name: ActivityIngredient

  attr_accessible :title, :video_url, as: :admin

  def optional_equipment
    equipment.where(optional: true)
  end

  def required_equipment
    equipment.where(optional: false)
  end

  def video
    build_video_url(video_url)
  end
end

