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

  def admin?
    false
  end

  def profile_complete?
    chef_type.present?
  end
end

