class PollsController < ApplicationController
  def index
    @polls = Poll.order('created_at DESC').page(params[:page]).per(12)
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def show_as_json
    @poll = Poll.find(params[:id])

    respond_to do |format|
      format.json { render :json => @poll.to_json(:include => :poll_items) }
    end
  end
end