class User < ActiveRecord::Base
  include User::Facebook

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :location, :quote, :website
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :provider, :uid, as: :admin

  validates_presence_of :name

  def as_json(options={})
    {
      id: id,
      name: name,
      email: email,
      location: location,
      website: website,
      quote: quote
    }
  end

end
