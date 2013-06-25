class PollsController < ApplicationController
  def index
    @polls = Poll.order('created_at DESC').page(params[:page]).per(12)
  end

  def show
    @poll = Poll.find(params[:id])
  end
end