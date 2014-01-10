class StreamsController < ApplicationController

  def index
    streams_data = Stream.all_events
    @streams = Kaminari::paginate_array(streams_data).page(params[:page]).per(5)
    render :json => @streams, root: false
  end

  def show
    @stream = Event.find(params[:id])
    render :json => @stream.to_json(:include => [:user, :trackable])
  end

  def feed

  end

end