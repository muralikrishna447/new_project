class ChefstepsBloom
  def self.encrypt(string)
    require 'openssl'
    require 'base64'
    require 'openssl/cipher'
    require 'openssl/digest'

    aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    aes.encrypt
    aes.key = Digest::SHA256.digest('xchefstepscRP9pJomgiluvfoodNTJto') 
    aes.iv  = 'chefsteps1234567'

    encrypted = Base64.encode64( aes.update(string) << aes.final )
    encrypted
  end
end