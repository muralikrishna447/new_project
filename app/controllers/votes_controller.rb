class VotesController < ApplicationController
  before_filter :authenticate_user!, only: [:create]

  # This is clearly the wrong way to be using this route, for both create and destroy, but to fix it would require
  # some changes to the angular controller to get the whole vote object so we could delete by vote id, instead of just
  # the user votes array, and no time for that this moment.
  def create
    if params[:votable_type] && params[:votable_id]
      if params[:dir] && (params[:dir].to_i > 0)
        @vote = Vote.new(votable_type: params[:votable_type], votable_id: params[:votable_id])
        @vote.user_id = current_user.id
        if @vote.save
          track_event @vote
        end
      else
        Vote.where(votable_type: params[:votable_type], votable_id: params[:votable_id], user_id: current_user.id).destroy_all
      end
    end
    render nothing: true
    # redirect_to request.referrer
  end


end