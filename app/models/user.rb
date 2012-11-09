class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, as: :admin

  validates_presence_of :name

  def self.connect_user_with_facebook(auth)
    user = find_existing_user(auth.provider, auth.uid)
    return user if user

    create_user_from_auth(auth)
  end

  def assign_from_auth(auth)
    auth_attributes = {
      provider: auth.provider,
      uid: auth.uid,
    }
    auth_attributes.merge!({
      name: auth.extra.raw_info.name,
      password: Devise.friendly_token[0,20]
    }) unless persisted?

    assign_attributes(auth_attributes, without_protection: true)
  end

  private

  def self.find_existing_user(provider, uid)
    User.where(provider: provider, uid: uid).first
  end

  def self.create_user_from_auth(auth)
    user = User.find_or_initialize_by_email(auth.info.email)
    user.assign_from_auth(auth)
    user.save unless user.id.nil?
    user
  end
end
