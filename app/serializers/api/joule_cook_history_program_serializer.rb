class Api::JouleCookHistoryItemSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :uuid, :idempotency_id, :start_time, :started_from
    
  def program
    {
      cook_time: object.cook_time
      guide: object.guide_id
      holding_temperature: object.holding_temperature
      program_type: object.program_type
      set_point: object.set_point
      cook_id: object.cook_id
      delayed_start: object.delayed_start
      wait_for_preheat: object.wait_for_preheat
      program_metadata: program_metadata
    }
  end
  
  def program_metadata
    {
      guideId: object.guide_id,
      cookId: object.cook_id,
      timerId: object.timer_id
    }
  end
  
end
