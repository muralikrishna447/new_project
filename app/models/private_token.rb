class PrivateToken < ActiveRecord::Base
  attr_accessible :token

  def self.token
    PrivateToken.exists? && PrivateToken.first.token
  end

  def self.valid?(token)
    token == self.token
  end
end
