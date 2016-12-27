class Api::JouleCookHistoryProgramSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :cook_time, :guide_id, :holding_temperature, :program_type, :set_point, :timer_id, :cook_id
  
  def created_at
    object.created_at.strftime("%s").to_i
  end
end
