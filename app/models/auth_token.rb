class AuthToken
  attr_reader :claim

  def initialize(claim)
    @claim = claim
  end

  def [](key)
    @claim[key]
  end

  def age
    Time.now.to_i - self[:iat]
  end

  def to_jwt(key = nil)
    unless key
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    end
    jwt = JSON::JWT.new(claim.as_json).sign(key.to_s)
    jwt.to_s
  end

  def self.from_string(token)
    begin
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      claim = JSON::JWT.decode(token, key.to_s)
      AuthToken.new claim
    rescue JSON::JWT::InvalidFormat => e
      Rails.logger.warn "[auth] invalid token format for token [#{token}]"
      raise e
    rescue JSON::JWS::VerificationFailed => e
      Rails.logger.warn "[auth] token verification failed for token [#{token}]"
      raise e
    end
  end

  def self.provide_short_lived(token_string)
    begin
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      claim = JSON::JWT.decode(token_string, key.to_s)
      exp = (Time.now + 10.minutes).to_i
      claim['iat'] = Time.now.to_i # Keep everything the except use a new issued_at because its a different token
      claim['exp'] = exp
      AuthToken.new claim
    rescue JSON::JWT::InvalidFormat => e
      Rails.logger.warn "[auth] invalid token format for token [#{token_string}]"
      raise e
    rescue JSON::JWS::VerificationFailed => e
      Rails.logger.warn "[auth] token verification failed for token [#{token_string}]"
      raise e
    end
  end

  def self.upgrade_token(token_string)
    begin
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      claim = JSON::JWT.decode(token_string, key.to_s)
      exp = (Time.now + 10.minutes).to_i
      claim['iat'] = Time.now.to_i # Keep everything the except use a new issued_at because its a different token
      claim.delete('exp')
      AuthToken.new claim
    rescue JSON::JWT::InvalidFormat => e
      Rails.logger.warn "[auth] invalid token format for token [#{token_string}]"
      raise e
    rescue JSON::JWS::VerificationFailed => e
      Rails.logger.warn "[auth] token verification failed for token [#{token_string}]"
      raise e
    end
  end
end
