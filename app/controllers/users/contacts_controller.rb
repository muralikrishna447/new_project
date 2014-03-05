class Users::ContactsController < ApplicationController
  def google
    @contacts = current_user.gather_google_contacts(google_app_id, google_secret)
    render(json: @contacts)
  end

  def invite
    emails = params[:emails]
    UserMailer.invitations(emails, current_user).deliver
    render(json: {status: :success})
  end

  def gather_friends
    friends_from_facebook = params[:friends_from_facebook] || []
    friends_from_facebook = friends_from_facebook.map{|c| c["id"] } if params[:friends_from_facebook]
    friends_from_google = []
    if current_user.google_user_id
      current_user.gather_contacts(google_app_id, google_secret) do |contacts|
        friends_from_google = contacts.map{|c| c[:email]} unless contacts.blank?
      end
    end
    @users = User.where("facebook_user_id in (?) or email in (?)", friends_from_facebook, friends_from_google)
    # @users.reject!{|u| current_user.follows?(u) }
    render(json: @users.map{|u| u.attributes.merge(following: current_user.follows?(u)) })
  end
end