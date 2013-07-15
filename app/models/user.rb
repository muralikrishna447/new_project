class User < ActiveRecord::Base
  has_merit

  include User::Facebook
  include Gravtastic
  include UpdateWhitelistAttributes
  extend FriendlyId

  friendly_id :name, use: :slugged

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  has_many :quizzes, class_name: QuizSession, dependent: :destroy, inverse_of: :user
  has_many :user_activities
  has_many :activities, through: :user_activities
  has_many :enrollments
  has_many :courses, through: :enrollments

  has_many :uploads
  has_many :activities, through: :uploads

  has_many :events
  has_many :likes
  has_many :votes

  has_many :created_activities, class_name: 'Activity', foreign_key: 'creator'

  serialize :viewed_activities, Array

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id, :role

  validates_presence_of :name

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  ROLES = %w[admin moderator user banned]

  def role?(base_role)
    ROLES.index(base_role.to_s) >= ROLES.index(role)
  end

  def role
    read_attribute(:role) || "user"
  end


  def admin?
    self.role == "admin"
  end

  def profile_complete?
    chef_type.present?
  end

  def viewed_activities_in_course(course)
    # events.scoped_by('Inclusion', 'show').where(inclusions: {course_id: 8}).map(&:trackable).select{|a| a.published=true}.uniq
    course.inclusions.joins(:events).where('events.user_id = ?', self.id).map(&:activity).select{|a| a.published=true}.uniq
  end

  def last_viewed_activity_in_course(course)
    last_viewed = events.scoped_by('Inclusion', 'show').map(&:trackable).select{|i| i.course_id == course.id}.first
    if last_viewed
      last_viewed.activity
    end
  end

  def likes_object?(likeable_object)
    Like.where('user_id = ? AND likeable_type = ? AND likeable_id = ?', self.id, likeable_object.class.to_s, likeable_object.id)
  end

end

