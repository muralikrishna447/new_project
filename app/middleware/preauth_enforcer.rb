class PreauthEnforcer
  # NOT FOR PROD! Enforces presence of a pre-auth cookie
  def initialize(app, exceptions = [])
    @app = app
    @exceptions = exceptions
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
    puts request.cookie_jar.inspect 
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
