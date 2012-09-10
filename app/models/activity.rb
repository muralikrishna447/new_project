class Activity < ActiveRecord::Base
  has_many :steps, dependent: :destroy
  has_many :equipment, through: :activity_equipment
  has_many :ingredients, through: :activity_ingredient

  attr_accessible :title, :video_url, as: :admin

  def video?
    video_url.present?
  end
end

