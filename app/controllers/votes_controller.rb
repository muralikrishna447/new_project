class VotesController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  def create
    if params[:votable_type] && params[:votable_id]
      @vote = Vote.new(votable_type: params[:votable_type], votable_id: params[:votable_id])
      @vote.user_id = current_user.id
      if @vote.save
        track_event @vote
      end
    end
    # render nothing: true
    redirect_to request.referrer
  end

end