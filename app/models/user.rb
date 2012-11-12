class User < ActiveRecord::Base
  include User::Facebook
  include Gravtastic

  gravtastic

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, as: :admin

  validates_presence_of :name

  def profile_image_url(default_image_url)
    if connected_with_facebook?
      facebook_image_url(uid)
    else
      gravatar_url(default: default_image_url)
    end
  end

end

