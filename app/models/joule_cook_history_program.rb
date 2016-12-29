class JouleCookHistoryProgram < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :cook_time, :guide_id, :holding_temperature, 
  :program_id, :program_type, :set_point, :timer_id, :cook_id,
  :delayed_start, :wait_for_preheat, :predictive
  
end
