class PreauthEnforcer
  def initialize(app, exceptions = [], restrictions = [])
    @app = app
    @exceptions = exceptions
    @restrictions = restrictions
    Rails.logger.info("[preauth] Initializing with exceptions #{@exceptions}")
  end

  def call(env)
    passthrough = passthrough?(env)
    preauthed = preauthed?(env)
    Rails.logger.info("[preauth] Passthrough: #{passthrough} Preauthed: #{preauthed}")
    if passthrough || preauthed
      @app.call(env)
    else
      [401, {}, ["Unauthorized - preauthorization required"]]
    end
  end

  def passthrough?(env)
    path = env['REQUEST_PATH']

    return true if ENV['CS_PREAUTH_SUPPRESS'] == 'SUPPRESS' # sometimes we need to test that things work like in production

    # Restrictions are always applied first
    @restrictions.each do |restriction|
      if restriction.match(path)
        Rails.logger.info("[preauth] Request for path [#{path}] matches restriction #{restriction}")
        return false
      end
    end

    @exceptions.each do |exception|
      if exception.match(path)
        Rails.logger.info("[preauth] Request for path [#{path}] matches exception #{exception}")
        return true
      end
    end
    return false
  end
  
  def preauthed?(env)
    request = ActionDispatch::Request.new(env)
    raw_token = request.cookie_jar[:cs_preauth]

    if raw_token.nil?
      Rails.logger.info "[preauth] No cs_preauth token present"
      return false
    end
    token = AuthToken.from_string(raw_token)
    aa = ActorAddress.find_for_token(token)
    if aa.nil?
      Rails.logger.info "[preauth] No actor address found for token #{raw_token}"
      return false
    end
    unless aa.actor.admin
      Rails.logger.info "[preauth] Actor #{aa.inspect} is not admin, rejecting."
      return false
    end
    Rails.logger.info "[preauth] Accepting preauth token from user #{aa.actor.id}"
    return true
  end
end
