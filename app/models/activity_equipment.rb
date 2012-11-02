class ActivityEquipment < ActiveRecord::Base
  include RankedModel
  ranks :equipment_order, with_same: :activity_id

  belongs_to :activity, touch: true, inverse_of: :equipment
  belongs_to :equipment, inverse_of: :activity_equipment

  validates :activity_id, presence: true
  validates :equipment_id, presence: true
  attr_accessible :activity_id, :equipment_id, :optional, :equipment_order_position

  delegate :title, :product_url, :product_url?, to: :equipment

  scope :ordered, rank(:equipment_order)

  scope :optional, where(optional: true)
  scope :required, where(optional: false)
end

