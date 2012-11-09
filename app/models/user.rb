class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, as: :admin

  validates_presence_of :name

  def self.facebook_connected_user(auth)
    connected_user(auth) || connect_via_email(auth)
  end

  def assign_from_facebook(auth)
    attrs = {
      provider: auth.provider,
      uid: auth.uid,
      name: self.name.blank? ? auth.extra.raw_info.name : self.name
    }
    attrs.merge!({password: Devise.friendly_token[0,20]}) unless persisted?
    assign_attributes(attrs, without_protection: true)
    self
  end

  private

  def self.connected_user(auth)
    User.where(provider: auth.provider, uid: auth.uid).first
  end

  def self.connect_via_email(auth)
    user = User.where(email: auth.info.email).first
    return if user.nil?
    user.assign_from_facebook(auth)
  end
end
