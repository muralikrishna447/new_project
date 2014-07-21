class BloomController < ApplicationController
  def index

  end

  def forum
    if current_user
      render layout: false
    else
      redirect_to(sign_in_path(returnTo: '/forum'), notice: "You must be signed in to view the Forum")
    end
  end

  def betainvite
    render layout: false
  end
end