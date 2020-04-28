class EventsController < ApplicationController

  before_filter :authenticate_user!, only: [:create]

  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      render json: @event
    end
  end

  private
  def event_params
    params.require(:event).permit(:action, :user_id, :trackable, :trackable_id, :trackable_type, :viewed)
  end

end