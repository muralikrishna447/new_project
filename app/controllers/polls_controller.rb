class PollsController < ApplicationController
  def index
    @polls = Poll.order('created_at DESC')
  end
end