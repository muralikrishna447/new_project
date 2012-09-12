class MailingListController < ActionController::Base
  include MailingListHelper
  expose(:placeholder_text) { "Thanks for subscribing"}

  def subscribe
    email = params[:email]
    @chimp = MailChimpListManager.new(MAILCHIMP_LIST)

    if @chimp.subscribe_user(email)
      sleep(20)
      render 'success', format: :js
    else
      render nothing: true, status: :internal_server_error
    end
  end
end

