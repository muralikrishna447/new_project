class MailingListController < ActionController::Base
  include MailingListHelper

  def subscribe
    email = params[:email]
    @chimp = MailChimpListManager.new

    if @chimp.subscribe_user(email)
      @placeholder = "Thanks for subscribing"
      render 'success', format: :js
    else
      @placeholder = "Something went wrong, please try again..."
      render 'success', format: :js
    end
  end
end

