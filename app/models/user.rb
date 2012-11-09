class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, as: :admin

  validates_presence_of :name

  def self.find_for_facebook_oauth(auth)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    user = create_user_from_auth(auth) unless user
    user
  end

  private

  def self.create_user_from_auth(auth)
    user = User.find_or_initialize_by_email(auth.info.email)
    user.update_attributes(
      name: auth.extra.raw_info.name,
      provider: auth.provider,
      uid: auth.uid,
      password: Devise.friendly_token[0,20]
    )
    user
  end
end
