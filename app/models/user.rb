class User < ActiveRecord::Base
  include ApplicationHelper
  include User::Facebook
  include Gravtastic

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type

  validates_presence_of :name

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  def as_json(options={})
    {
      id: id,
      name: name,
      email: email,
      location: location,
      website: website,
      quote: quote,
      chef_type: chef_type
    }
  end

  def profile_image_url(default_image_url)
    if connected_with_facebook?
      facebook_image_url(uid)
    else
      gravatar_url(default: default_image_url)
    end
  end

  def profile_edit_url
    connected_with_facebook? ? facebook_edit_url : gravatar_edit_url
  end
end

