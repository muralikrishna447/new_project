class JouleCookHistoryProgram < ActiveRecord::Base
  attr_accessible :cook_time, :guide_id, :holding_temperature, 
  :program_id, :history_item_type, :set_point, :timer_id, :cook_id,
  :delayed_start, :wait_for_preheat, :predictive
  
end
