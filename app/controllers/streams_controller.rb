class StreamsController < ApplicationController
  
  before_filter :authenticate_user!

  def index
    @stream = Stream.followings(current_user)
    render :json => @stream.to_json(:include => :user)
  end

end