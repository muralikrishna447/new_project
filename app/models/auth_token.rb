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
    key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    claim = JSON::JWT.decode(token, key.to_s)
    AuthToken.new claim
  end
end
