class User < ActiveRecord::Base
  has_merit

  include User::Facebook
  include Gravtastic
  include UpdateWhitelistAttributes
  extend FriendlyId

  friendly_id :name, use: :slugged

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  has_many :followerships
  has_many :followers, through: :followerships
  has_many :inverse_followerships, class_name: 'Followership', foreign_key: 'follower_id'
  has_many :followings, through: :inverse_followerships, source: :user

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

  ROLES = %w[admin contractor moderator user banned]

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
    # course.inclusions.joins(:events).where('events.user_id = ?', self.id).map(&:activity).select{|a| a.published=true}.uniq
    course.activities.joins(:events).where('events.user_id = ?', self.id).select{|a| a.published=true}.uniq
  end

  def last_viewed_activity_in_course(course)
    # last_viewed = events.scoped_by('Inclusion', 'show').map(&:trackable).select{|i| i.course_id == course.id}.first
    # if last_viewed
    #   last_viewed.activity
    # end
    events.scoped_by('Activity', 'show').order('created_at asc').where(trackable_id: course.activity_ids).last.trackable
  end

  def likes_object?(likeable_object)
    Like.where('user_id = ? AND likeable_type = ? AND likeable_id = ?', self.id, likeable_object.class.to_s, likeable_object.id).any?
  end

  def received_stream
    events.timeline.where(action: 'received_create').group_by{|e| [e.group_type, e.group_name]}
    # timeline.group_by{|e| e.group_name}
  end

  def created_stream
    events.includes(:trackable).timeline.where('action != ?', 'received_create').group_by{|e| [e.group_type, e.group_name]}
    # timeline.group_by{|e| e.group_name}
  end

  def stream
    # stream = []
    # followings.each do |following|
    #   following.created_stream.each do |group|
    #     stream << group
    #   end
    # end
    # stream.sort_by{|group| group[1].first.created_at}.reverse
    stream_events = []
    followings.each do |following|
      following.events.includes(:trackable).timeline.where('action != ?', 'received_create').each do |event|
        stream_events << event
      end
    end
    stream_events.group_by{|e| [e.group_type, e.group_name]}.sort_by{|group| group[1].first.created_at}.reverse
  end

  def followings_stream
    stream_events = Event.includes(:trackable).timeline.where(user_id: self.following_ids).where('action != ?', 'received_create')
    # stream_events.group_by{|e| [e.group_type, e.group_name]}.sort_by{|group| group[1].first.created_at}.reverse
    stream_events.uniq!{|e| e.group_name}
  end

  def follow(user)
    followership = Followership.find_by_user_id_and_follower_id(user.id,self.id) || Followership.create(user_id: user.id, follower_id: self.id)
  end

  def unfollow(user)
    Followership.find_by_user_id_and_follower_id(user.id,self.id).destroy
  end

  def follows?(user)
    followings.include?(user)
  end

  def profile_image_id
    self.image_id ||= '{"url":"https://www.filepicker.io/api/file/U2RccgsARPyMmzJ5Ao0c","filename":"default-avatar@2x.png","mimetype":"image/png","size":6356,"key":"users_uploads/FhbcOZpQYKJU8nHeJg1j_default-avatar@2x.png","isWriteable":true}'
  end

end

