class Api::JouleCookHistoryItemSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :uuid, :start_time, :started_from, :program
    
  def program
    {
      cookTime: object.cook_time,
      guide: object.guide_id,
      holdingTemperature: object.holding_temperature,
      programType: object.program_type,
      setPoint: object.set_point,
      cookId: object.cook_id,
      delayedStart: object.delayed_start,
      waitForPreheat: object.wait_for_preheat,
      programMetadata: {
        guideId: object.guide_id,
        cookId: object.cook_id,
        timerId: object.timer_id,
        programId: object.program_id
      }
    }
  end

end
