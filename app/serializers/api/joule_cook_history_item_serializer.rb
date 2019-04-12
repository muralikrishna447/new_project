class Api::JouleCookHistoryItemSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :external_id, :start_time, :started_from, :program
    
  def program
    {
      cookTime: object.cook_time,
      guide: object.guide_id,
      programType: object.program_type,
      turboCookState: object.turbo_cook_state,
      setPoint: object.set_point,
      cookId: object.cook_id,
      programMetadata: {
        guideId: object.guide_id,
        cookId: object.cook_id,
        timerId: object.timer_id,
        programId: object.program_id
      }
    }
  end

end
