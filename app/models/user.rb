class User < ActiveRecord::Base
  include ApplicationHelper
  include User::Facebook
  include Gravtastic

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :location, :quote, :website

  validates_presence_of :name

end

