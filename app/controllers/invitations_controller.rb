class InvitationsController < ApplicationController
  def welcome
    session[:referrer_id] = params[:referrer_id]
    session[:referred_from] = params[:referred_from]
    # render("home/index")
    redirect_to root_path
  end
end
