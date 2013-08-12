class StreamsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @streams = Kaminari::paginate_array(Stream.followings(current_user)).page(params[:page]).per(12)
    render :json => @streams, root: false
  end

  def show
    @stream = Event.find(params[:id])
    render :json => @stream.to_json(:include => [:user, :trackable])
  end

end