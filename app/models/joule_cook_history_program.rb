class JouleCookHistoryProgram < ActiveRecord::Base
  attr_accessible :cook_time, :guide_id, :holding_temperature, :program_id, :program_type, :set_point, :timer_id
  
end
