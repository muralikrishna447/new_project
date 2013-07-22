class AssemblyInclusion < ActiveRecord::Base
  attr_accessible :includable_id, :includable_type, :position
end
