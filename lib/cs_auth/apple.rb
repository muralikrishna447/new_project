module CsAuth::Apple
  class InvalidTokenError < StandardError
  end

  JWK_CACHE_KEY = 'appleid.apple.com/auth/keys'

  @@fallback_jwk_set = nil

  # Set a fallback JWK public key set in case using the live key set
  # from apple.com fails.
  def self.initialize_fallback_jwk_set(fallback_jwk_set)
    @@fallback_jwk_set = fallback_jwk_set
  end

  # Downloads the live JWK public key set from apple.com
  def self.live_jwk_set
    Retriable.retriable tries: 3 do
      response = RestClient.get 'https://appleid.apple.com/auth/keys'
      JSON::JWK::Set.new(JSON.parse(response.body))
    end
  end

  # Fetch and cache the live JWK public key set from Apple for an hour.
  # In case of failure, use the fallback.
  def self.jwk_set
    begin
      result = Rails.cache.fetch(JWK_CACHE_KEY, expires_in: 1.hour) { live_jwk_set() }
    rescue => e
      Rails.logger.warn "Failed to fetch Apple JWK public key set, using fallback: #{e.message}"
      raise 'Fallback JWK set is not initialized' unless @@fallback_jwk_set
      result = @@fallback_jwk_set
    end

    result
  end

  def self.decode_and_validate_token(identity_token, auth_code)
    decoded_token = decode_token(identity_token)

    # Authorize the code, which gives us a token containing the user ID.
    # We want to validate the authenticity of the authorized token
    # and that the token from the client is for the same user ID.
    authorized_token = authorized_token_for_code(auth_code, decoded_token['aud'])
    apple_user_id = authorized_token['sub']
    validate_decoded_token(authorized_token, apple_user_id)

    validate_decoded_token(decoded_token, apple_user_id)
    decoded_token
  end

  def self.authorized_token_for_code(auth_code, client_id)
    response = nil
    begin
      Retriable.retriable tries: 3 do
        response = RestClient.post('https://appleid.apple.com/auth/token', {
          client_id: client_id,
          client_secret: client_secret(client_id),
          code: auth_code,
          grant_type: 'authorization_code'
        })
      end
    rescue RestClient::ExceptionWithResponse => e
      if e.response.code == 400
        raise CsAuth::Apple::InvalidTokenError, "Failed to authorize Apple auth code: #{e.response.body}"
      end
      raise e
    end
    response_json = JSON.parse(response.body)
    decode_token(response_json['id_token'])
  end

  def self.client_secret(client_id)
    raise 'APPLE_TEAM_ID undefined' if ENV['APPLE_TEAM_ID'].blank?
    raise 'APPLE_SECRET_KEY undefined' if ENV['APPLE_SECRET_KEY'].blank?
    raise 'APPLE_SECRET_KEY_ID undefined' if ENV['APPLE_SECRET_KEY_ID'].blank?

    key = OpenSSL::PKey::EC.new(ENV['APPLE_SECRET_KEY'])
    headers = { 'kid' => ENV['APPLE_SECRET_KEY_ID'] }
    claims = {
      'iss' => ENV['APPLE_TEAM_ID'],
      'iat' => Time.now.to_i,
      'exp' => (Time.now + 5.minutes).to_i,
      'aud' => 'https://appleid.apple.com',
      'sub' => client_id
    }
    JWT.encode(claims, key, 'ES256', headers)
  end

  def self.decode_token(identity_token)
    begin
      decoded_token = JSON::JWT.decode(identity_token, jwk_set())
    rescue JSON::JWT::Exception => e
      raise CsAuth::Apple::InvalidTokenError, "JWT token decode failed: #{e.message}"
    end
    decoded_token
  end

  def self.validate_decoded_token(decoded_token, apple_user_id)
    validate_token_iss(decoded_token)
    validate_token_aud(decoded_token)
    validate_token_sub(decoded_token, apple_user_id)
    validate_token_exp(decoded_token)
    validate_token_iat(decoded_token)
    validate_token_email_present(decoded_token)
    validate_token_email_verified(decoded_token)
    true
  end

  def self.validate_token_iss(decoded_token)
    if decoded_token['iss'] != 'https://appleid.apple.com'
      raise CsAuth::Apple::InvalidTokenError, "Invalid token iss #{decoded_token['iss']}"
    end
    true
  end

  def self.validate_token_aud(decoded_token)
    # We accept tokens from both the Joule app and the website.
    if decoded_token['aud'] != 'com.chefsteps.circulator' && decoded_token['aud'] != 'com.chefsteps.web'
      raise CsAuth::Apple::InvalidTokenError, "Invalid token aud #{decoded_token['aud']}"
    end
    true
  end

  def self.validate_token_sub(decoded_token, apple_user_id)
    # The user ID encoded in the token should match what the client passed in
    if decoded_token['sub'] != apple_user_id
      raise CsAuth::Apple::InvalidTokenError, "Invalid token sub #{decoded_token['sub']}"
    end
    true
  end

  def self.validate_token_exp(decoded_token)
    # The token expiration must be in the future.
    unless decoded_token['exp'].present? && Time.at(decoded_token['exp']) > Time.now
      raise CsAuth::Apple::InvalidTokenError, "Invalid token exp #{decoded_token['exp']}"
    end
    true
  end

  def self.validate_token_iat(decoded_token)
    # The token must have been issued in the last 30 seconds.
    unless decoded_token['iat'].present? && Time.at(decoded_token['iat']).between?(5.minutes.ago, Time.now)
      raise CsAuth::Apple::InvalidTokenError, "Invalid token iat #{decoded_token['iat']}"
    end
    true
  end

  def self.validate_token_email_present(decoded_token)
    # Email must be set (this is likely not a possible case).
    if decoded_token['email'].blank?
      raise CsAuth::Apple::InvalidTokenError, "Email is blank"
    end
    true
  end

  def self.validate_token_email_verified(decoded_token)
    if decoded_token['email_verified'] != true.to_s
      raise CsAuth::Apple::InvalidTokenError, "Email must be verified"
    end
    true
  end
end
