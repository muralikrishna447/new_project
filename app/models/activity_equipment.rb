class ActivityEquipment < ActiveRecord::Base
  belongs_to :activity, inverse_of: :equipment
  belongs_to :equipment, inverse_of: :activities

  attr_accessible :activity_id, :equipment_id, as: :admin
end

