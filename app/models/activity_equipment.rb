class ActivityEquipment < ActiveRecord::Base

  belongs_to :activity, touch: true, inverse_of: :equipment
  belongs_to :equipment, inverse_of: :activity_equipment

  validates :activity_id, presence: true
  validates :equipment_id, presence: true

  delegate :title, :product_url, :product_url?, to: :equipment

  scope :ordered, -> { order(:equipment_order) }
  scope :optional, -> { where(optional: true) }
  scope :required, -> { where(optional: false) }

  default_scope { ordered }
end

