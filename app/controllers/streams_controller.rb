class StreamsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @streams = Stream.followings(current_user)
    render :json => @streams.to_json(:include => :user)
  end

  def show
    @stream = Event.find(params[:id])
    render :json => @stream.to_json(:include => [:user, :trackable])
  end

end