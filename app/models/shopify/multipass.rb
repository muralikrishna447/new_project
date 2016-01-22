# Adapted from shopping_controller
class Shopify::Multipass
  def initialize
    ### Use the Multipass secret to derive two cryptographic keys,
    ### one for encryption, one for signing
    key_material = OpenSSL::Digest::Digest.new("sha256").digest(Rails.configuration.shopify[:multipass_secret])
    @encryption_key = key_material[ 0,16]
    @signature_key  = key_material[16,16]
  end
  
  def self.for_user(user, return_to)
    multipass = Shopify::Multipass.new
    # TODO - add user IP
    user_hash = 
      {
        email: user.email,
        first_name: user.name.split(' ')[0],
        last_name: (user.name.split(' ').size > 1 ? user.name.split(' ')[1] : nil),
        identifier: user.id,
        return_to: return_to
      }
    multipass.generate_token(user_hash)
  end
  

  def generate_token(customer_data_hash)
    ### Store the current time in ISO8601 format.
    ### The token will only be valid for a small timeframe around this timestamp.
    customer_data_hash["created_at"] = Time.now.iso8601

    Rails.logger.info("Generating multipass token with data [#{customer_data_hash.inspect}]")
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
