class EventsController < ApplicationController

  before_filter :authenticate_user!, only: [:create]

  def create
    @event = Event.new(params[:event])
    @event.user_id = current_user.id
    if @event.save
      render json: @event
    end
  end

end