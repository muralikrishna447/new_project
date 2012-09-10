class ActivityEquipment < ActiveRecord::Base
  belongs_to :activity
  belongs_to :equipment
end

