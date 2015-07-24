require "openssl"
require "base64"
require "time"
require "json"

if Rails.env.production? || Rails.env.staging? || Rails.env.staging2?
  Rails.configuration.shopify = {
    api_key: ENV["SHOPIFY_KEY"],
    password: ENV["SHOPIFY_SECRET"],
    multipass_secret: ENV["SHOPIFY_MULTIPASS_SECRET"]
  }
elsif Rails.env.test?
  Rails.configuration.shopify = {
    api_key: '123',
    password:  '321',
    multipass_secret: "abc"
  }
else
  Rails.configuration.shopify = {
    api_key: 'c47683a274bb9c27373355f2094a0e69',
    password:  '92aa619112cc0c5472bb1151a6b8e5dc',
    multipass_secret: ENV["SHOPIFY_MULTIPASS_SECRET"]
  }
end
ShopifyAPI::Base.site = "https://#{Rails.configuration.shopify[:api_key]}:#{Rails.configuration.shopify[:password]}@delve.myshopify.com/admin"

class ShopifyMultipass
  def initialize
    ### Use the Multipass secret to derive two cryptographic keys,
    ### one for encryption, one for signing
    key_material = OpenSSL::Digest::Digest.new("sha256").digest(Rails.configuration.shopify[:multipass_secret])
    @encryption_key = key_material[ 0,16]
    @signature_key  = key_material[16,16]
  end

  def generate_token(customer_data_hash)
    ### Store the current time in ISO8601 format.
    ### The token will only be valid for a small timeframe around this timestamp.
    customer_data_hash["created_at"] = Time.now.iso8601

    ### Serialize the customer data to JSON and encrypt it
    ciphertext = encrypt(customer_data_hash.to_json)

    ### Create a signature (message authentication code) of the ciphertext
    ### and encode everything using URL-safe Base64 (RFC 4648)
    Base64.urlsafe_encode64(ciphertext + sign(ciphertext))
  end

  private

  def encrypt(plaintext)
    cipher = OpenSSL::Cipher::Cipher.new("aes-128-cbc")
    cipher.encrypt
    cipher.key = @encryption_key

    ### Use a random IV
    cipher.iv = iv = cipher.random_iv

    ### Use IV as first block of ciphertext
    iv + cipher.update(plaintext) + cipher.final
  end

  def sign(data)
    OpenSSL::HMAC.digest("sha256", @signature_key, data)
  end
end
