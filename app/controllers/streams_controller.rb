class StreamsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    if current_user.followings.any?
      streams_data = Stream.followings(current_user)
    else
      streams_data = Stream.all_events
    end
    @streams = Kaminari::paginate_array(streams_data).page(params[:page]).per(10)
    render :json => @streams, root: false
  end

  def show
    @stream = Event.find(params[:id])
    render :json => @stream.to_json(:include => [:user, :trackable])
  end

end