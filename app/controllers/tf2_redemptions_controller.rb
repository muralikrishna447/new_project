class Tf2RedemptionsController < ApplicationController
  before_filter :auth_user, except: [:index]
  skip_before_filter :verify_authenticity_token

  # Landing page description
  def index
  end

  # Show current user's redemption codes
  def show
    @message = params[:message]
    @current_redemptions = current_user.tf2_redemptions
    @max_redemptions = current_user.max_tf2_redemptions
  end

  # Redeem a code for the current user
  def create
    if current_user.can_do_tf2_redemption?
      if Tf2Redemption.redeem!(current_user)
        redirect_to tf2_redemptions_path(message: "Successfully redeemed code. Have fun cooking and taunting.")
      else
        redirect_to tf2_redemptions_path(message: "Sorry, something seemed to go wrong. Please try again")
      end
    else
      redirect_to tf2_redemptions_path(message: "Sorry, we don't see that you have any redemptions remaining.")
    end
  end

  def auth_user
    if !user_signed_in?
      redirect_to sign_in_path(return_to: tf2_redemptions_path)
    end
  end
end
