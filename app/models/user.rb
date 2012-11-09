class User < ActiveRecord::Base
  include User::Facebook
  include Gravtastic
  gravtastic

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, as: :admin

  validates_presence_of :name

  def connected_with_facebook?
    uid.present? && provider == 'facebook'
  end

  def image_url
    image_location = nil
    if connected_with_facebook?
      image_location = ApplicationHelper::facebook_image_url(uid)
    else
      image_location = gravatar_url if has_gravatar
    end
    image_location
  end

end

