class InvitationsController < ApplicationController
  def welcome
    if params[:referrer_id] && params[:referred_from]
      referrer = User.find(params[:referrer_id])
      session[:referrer_id] = referrer.id
      session[:referred_from] = params[:referred_from]
      set_referrer_in_mixpanel("#{session[:referred_from]} invitee visited")
      mixpanel.people.set(mixpanel_anonymous_id, {invited_from: params[:referred_from], invited_by: referrer.email, invited_by_id: referrer.id})
    end
    render("home/index")
    # redirect_to root_path
  end
end
