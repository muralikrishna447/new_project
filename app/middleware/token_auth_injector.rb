class TokenAuthInjector
  def initialize(app)
    @app = app
  end

  # TODO add librato metrics
  def call(env)
    session = env['rack.session']

    # Warden data is reliably and securly populated by warden manager
    unless session.has_key? 'warden.user.user.key'
      Rails.logger.info "[auth] no user logged in"
      return @app.call(env)
    end

    # Warden data is of the form ["User", [user_id], ...]
    warden_data = session['warden.user.user.key']
    user_id = warden_data[1][0]

    Rails.logger.info "[auth] current user #{user_id}"
    current_user = User.find_by_id(user_id)

    unless current_user
      Rails.logger.error "[auth] no user found for id #{user_id}"
      return @app.call(env)
    end

    aa = ActorAddress.find_for_user_and_unique_key(current_user, 'website')
    if aa
      Rails.logger.info "[auth] found existing website actor address #{aa.id} for user #{user_id}." if aa
    else
      Rails.logger.info "[auth] creating new website actor address for user #{user_id}"
      begin
        aa = ActorAddress.create_for_user(current_user, {unique_key: 'website'})
      rescue ActiveRecord::RecordNotUnique
        Rails.logger.info("[auth] Failed to create uplicate actor address - not setting token")
        # This occurs when there are multiple concurrent requests for a user
        # without an actor address.  Rather than retrying the request, let the other
        # concurrent thread set the token.
        return @app.call(env)
      end
    end

    cookie_jar = ActionDispatch::Request.new(env).cookie_jar
    token = cookie_jar[:_chefsteps_token]
    token_present = !token.nil?

    if token_present
      begin
        token = AuthToken.from_string(token)
      rescue JSON::JWT::InvalidFormat
        Rails.logger.info "[auth] invalid auth token #{token}"
        token_present = false
      end
    end

    # Logic here is a bit hairy but essentially we always want to give the user
    # a token if they have a valid session.  We won't always be this generous!

    valid_token = token_present ? aa.valid_token?(token) : false
    new_token = valid_token ? token.age < 2.days : false

    Rails.logger.info "[auth] token present: #{token_present} valid: #{valid_token} new: #{new_token}"

    unless new_token
      unless valid_token
        aa.double_increment()
      end

      cookie_jar[:_chefsteps_token]  = {
            value: aa.current_token.to_jwt,
            expires: 1.year.from_now
          }
    else
      Rails.logger.info "[auth] completely valid token"
    end

    @app.call(env)
  end
end
