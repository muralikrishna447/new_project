class Users::ContactsController < ApplicationController
  def google
    @contacts = current_user.gather_google_contacts(google_app_id, google_secret)
    render(json: @contacts)
  end

  def invite
    emails = params[:email]
    UserMailer.invitations(emails, current_user).deliver
    render(json: {status: :success})
  end
end