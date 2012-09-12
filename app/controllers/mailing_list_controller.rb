class MailingListController < ActionController::Base
  include MailingListHelper
  expose(:success_placeholder_text) { "Thanks for subscribing"}
  expose(:error_placeholder_text) { "Something went wrong, please try again..."}

  def subscribe
    email = params[:email]
    @chimp = MailChimpListManager.new(MAILCHIMP_LIST)

    if @chimp.subscribe_user(email)
      render 'success', format: :js
    else
      render 'error', format: :js
    end
  end
end

