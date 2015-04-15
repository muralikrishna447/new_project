class AuthToken
  attr_reader :claim

  def initialize(claim)
    @claim = claim
    @token = encrypt(@claim)
  end

  def [](key)
    @claim[key]
  end

  def to_s
    @token
  end

  def to_json
    {:token => @token}.to_json
  end

  def self.for_user(user, exp=nil, restrict_to=nil)
    claim = {
      iat: issued_at,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    }
    claim[:exp] = exp if exp
    claim[:restrictTo] = restrict_to if restrict_to

    AuthToken.new claim
  end

  def self.for_circulator(circulator, exp = nil)
    claim = {
      iat: issued_at,
      circulator: {
        id: circulator.id
      }
    }

    AuthToken.new claim
  end

  def self.from_encrypted(token)
    claim = decrypt(token)

    AuthToken.new claim
  end

  private
  def self.decrypt(token)
    key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    # NOTE - we should be using different keys for signing and encrypting
    decoded = JSON::JWT.decode(token, key)
    verified = JSON::JWT.decode(decoded.to_s, key.to_s)
    verified
  end

  def encrypt(claim)
    # Technically it signs and encrypts
    secret = ENV["AUTH_SECRET_KEY"]
    key = OpenSSL::PKey::RSA.new secret, 'cooksmarter'

    jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
    jwe = jws.encrypt(key.public_key)
    jwt = jwe.to_s
    jwt
  end

  def self.issued_at
    Time.now.to_i
  end
end
