class HomeController < ApplicationController

  def new_home
  end

  def embeddable_signup
    @hide_nav = true
    # the view file has removed in https://github.com/ChefSteps/ChefSteps/commit/6d2c82c4573993166af8d7f43b21d8ae6c7da864
    render_404
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
