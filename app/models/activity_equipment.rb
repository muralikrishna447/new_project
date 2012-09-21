class ActivityEquipment < ActiveRecord::Base
  belongs_to :activity, touch: true, inverse_of: :equipment
  belongs_to :equipment, inverse_of: :activity_equipment

  validates :activity_id, presence: true
  validates :equipment_id, presence: true
  attr_accessible :activity_id, :equipment_id, :optional, as: :admin

  delegate :title, :product_url, :product_url?, to: :equipment

  scope :optional, where(optional: true)
  scope :required, where(optional: false)
end

