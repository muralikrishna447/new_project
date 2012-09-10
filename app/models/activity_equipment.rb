class ActivityEquipment < ActiveRecord::Base
  belongs_to :activity
  belongs_to :equipment

  attr_accessible :activity_id, :equipment_id, as: :admin
end

