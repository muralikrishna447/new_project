class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, as: :admin

  validates_presence_of :name
end
