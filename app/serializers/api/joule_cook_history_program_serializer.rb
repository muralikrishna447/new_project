class Api::JouleCookHistoryProgramSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :cook_time, :guide, :holding_temperature, :program_type, 
  :set_point, :cook_id, :delayed_start, :wait_for_preheat, 
  :turbo, :predictive, :created_at, :program_metadata
  
  def created_at
    object.created_at.strftime("%s").to_i
  end
  
  def guide
    object.guide_id
  end
  
  def program_metadata
    {
      guideId: object.guide_id,
      cookId: object.cook_id,
    }
  end
  
end
