class HomeController < ApplicationController

  def new_home
  end

  def embeddable_signup
    @hide_nav = true
    render
  end

  def terms
  end

  def facebook_optout
    if request.post?
      GenericMailer.recipient_email('info@chefsteps.com', 'Facebook Audience Opt-Out', "Please opt out #{params[:email]} from our facebook custom audience").deliver
      redirect_to root_path
    end
  end
end
