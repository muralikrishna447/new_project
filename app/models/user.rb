class User < ActiveRecord::Base
  include User::Facebook
  include Gravtastic
  include UpdateWhitelistAttributes
  extend FriendlyId

  friendly_id :name, use: :slugged

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  has_many :quizzes, class_name: QuizSession, dependent: :destroy, inverse_of: :user
  has_many :user_activities
  has_many :activities, through: :user_activities

  serialize :viewed_activities, Array

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities

  validates_presence_of :name

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  def admin?
    false
  end

  def profile_complete?
    chef_type.present?
  end

end

