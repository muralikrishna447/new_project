class User < ActiveRecord::Base
  include User::Facebook
  include Gravtastic
  include UpdateWhitelistAttributes

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type

  validates_presence_of :name

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

end

