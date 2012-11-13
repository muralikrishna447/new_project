class ForumSsoController < ApplicationController
  DOZUKI_SECRET = '5J2HCTxVexxf9gXFtnuvsJ2kcFuiQeeL'
  FORUM_LOGIN_URL = 'http://forum.chefsteps.com/Guide/User/remote_login'

  before_filter :redirect_to_registration
  before_filter :authenticate_user!

  def authenticate
    redirect_to "#{FORUM_LOGIN_URL}?#{auth_info}"
  end

  private
  def auth_info
    query = {
      userid: current_user.id,
      email: current_user.email,
      name: current_user.name,
      t: Time.now.to_i
    }.to_query
    query += "&hash=#{calculate_hash(query)}"
  end

  def calculate_hash(query)
    Digest::SHA1.hexdigest("#{query}#{DOZUKI_SECRET}")
  end

  def redirect_to_registration
    redirect_to new_user_registration_path if params[:register]
  end
end
