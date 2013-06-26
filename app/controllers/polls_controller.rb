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
      puts @poll
      format.json { render :json => @poll.to_json }
    end
  end
end