class MailingListController < ActionController::Base
  include MailChimpHelper

  def subscribe
    email = params[:email]
    @chimp = MailChimpListManager.new(MAILCHIMP_LIST)
    if @chimp.subscribe_user(email)
      render nothing: true, status: :ok
    else
      render nothing: true, status: :internal_server_error
    end
  end
end

