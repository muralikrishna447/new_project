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
    # CLEANUP TODO
    {:token => @token, :status =>200}.to_json
  end

  def self.from_string(token)
    claim = decrypt(token)
    AuthToken.new claim
  end

  def self.from_encrypted(token)
    claim = decrypt(token)

    AuthToken.new claim
  end

  def only_signed
    # Technically it signs and encrypts
    secret = ENV["AUTH_SECRET_KEY"]
    key = OpenSSL::PKey::RSA.new secret, 'cooksmarter'

    jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
    #jwe = jws.encrypt(key.public_key)
    jwt = jws.to_s
    jwt
  end

  private
  def self.decrypt(token)
    key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    # NOTE - we should be using different keys for signing and encrypting
    decoded = JSON::JWT.decode(token, key.to_s)
    #verified = JSON::JWT.decode(decoded.to_s, key.to_s)
    decoded
  end

  def encrypt(claim)
    # Technically it signs and encrypts
    secret = ENV["AUTH_SECRET_KEY"]
    key = OpenSSL::PKey::RSA.new secret, 'cooksmarter'

    jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
    #jwe = jws.encrypt(key.public_key)
    #jwt = jwe.to_s
    jws.to_s
  end


  def self.issued_at
    Time.now.to_i
  end
end
