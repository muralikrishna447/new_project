class PrivateToken < ApplicationRecord

  def self.token
    PrivateToken.exists? && PrivateToken.first.token
  end

  def self.valid?(token)
    token == self.token
  end

  def self.new_token_string
    SecureRandom.urlsafe_base64
  end
end
