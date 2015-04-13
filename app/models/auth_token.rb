class AuthToken
  attr_reader :claim

  def initialize(claim)
    @claim = claim
    @token = sign_and_encrypt(@claim)
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

  def self.from_encrypted(token, verify=true)
    claim = decrypt(token)

    time_now = (Time.now.to_f * 1000).to_i
    if verify && claim[:exp] && claim[:exp] <= time_now
      return false # probably not right here!
    # elsif claims['restrictTo'] && verified['restrictTo'] != restrict_to
    #   return false
    end

    AuthToken.new claim
  end

  private
  def self.decrypt(token)
    key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    # NOTE - should be using different keys here
    decoded = JSON::JWT.decode(token, key)
    verified = JSON::JWT.decode(decoded.to_s, key.to_s)
    verified
  end

  def sign_and_encrypt(claim)
    secret = ENV["AUTH_SECRET_KEY"]
    key = OpenSSL::PKey::RSA.new secret, 'cooksmarter'

    jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
    jwe = jws.encrypt(key.public_key)
    jwt = jwe.to_s
    jwt
  end

  def self.issued_at
    (Time.now.to_f * 1000).to_i
  end
end
