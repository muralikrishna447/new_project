class StreamsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @streams = Stream.followings(current_user).first
    render :json => @streams
  end

  def show
    @stream = Event.find(params[:id])
    render :json => @stream.to_json(:include => [:user, :trackable])
  end

end