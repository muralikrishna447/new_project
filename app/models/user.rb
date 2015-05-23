class User < ActiveRecord::Base
  has_merit

  include User::Google
  include User::Facebook
  include Gravtastic
  include UpdateWhitelistAttributes
  extend FriendlyId

  friendly_id :name, use: :slugged

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  include ActsAsSanitized
  sanitize_input :bio, :name, :location, :website

  has_many :followerships
  has_many :followers, through: :followerships
  has_many :inverse_followerships, class_name: 'Followership', foreign_key: 'follower_id'
  has_many :followings, through: :inverse_followerships, source: :user

  has_many :user_activities
  has_many :activities, through: :user_activities
  has_many :enrollments
  has_many :enrollables, through: :enrollments

  has_many :uploads
  has_many :activities, through: :uploads

  has_many :events
  has_many :likes
  has_many :votes

  has_many :created_activities, class_name: 'Activity', foreign_key: 'creator'
  has_many :gift_certificates, inverse_of: :purchaser

  has_many :circulator_users
  has_many :circulators, through: :circulator_users

  has_many :actor_addresses, as: :actor

  serialize :viewed_activities, Array

  # scope :where_any, ->(column, key, value) { where("? = ANY (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore -> ?)", value, key) }
  # scope :where_all, ->(column, key, value) { where("? = ALL (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore -> ?)", value, key) }
  # scope :where_any, ->(column, key, value) { where("? = ANY (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore LIKE ?)", value, '%' + key + '%') }
  # scope :where_all, ->(column, key, value) { where("? = ALL (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore LIKE ?)", value, '%' + key + '%') }

  # scope :where_any, ->(column, key, value) { where("? LIKE ANY (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore -> ?)", '%' + value + '%', key) }
  # scope :where_all, ->(column, key, value) { where("? LIKE ALL (SELECT UNNEST(ARRAY[\"#{column}\"])::hstore -> ?)", '%' + value + '%', key) }

  scope :where_any, ->(column, key, value) { where("? LIKE ANY (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }
  scope :where_all, ->(column, key, value) { where("? LIKE ALL (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable, :omniauth_providers => [:google_oauth2]

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id, :referred_from, :referrer_id, :free_trial, :survey_results, :events_count, :signup_incentive_available

  # This is for active admin, so that it can edit the role (and so normal users can't edit their role)
  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id, :role, :referred_from, :referrer_id, as: :admin

  attr_accessor :free_trial, :skip_name_validation

  validates_presence_of :name, unless: Proc.new {|user| user.free_trial == true || user.skip_name_validation == true}

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  serialize :survey_results, ActiveRecord::Coders::NestedHstore

  ROLES = %w[admin contractor moderator collaborator user banned]

  include Searchable

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
    last_viewed = events.scoped_by('Activity', 'show').order('created_at asc').where(trackable_id: course.activity_ids).last
    if last_viewed
      last_viewed.trackable
    end
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
    if self.image_id.blank?
      '{"url":"https://www.filepicker.io/api/file/U2RccgsARPyMmzJ5Ao0c","filename":"default-avatar@2x.png","mimetype":"image/png","size":6356,"key":"users_uploads/FhbcOZpQYKJU8nHeJg1j_default-avatar@2x.png","isWriteable":true}'
    else
      self.image_id
    end
  end

  def avatar_url
    url = ActiveSupport::JSON.decode(self.profile_image_id)["url"]
    avatar_url = "#{url}/convert?fit=crop&w=70&h=70&cache=true".gsub("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
  end

  def enrolled?(enrollable)
    enrollment = Enrollment.where(user_id: self.id, enrollable_type: enrollable.class.to_s, enrollable_id: enrollable.id).first
    case
    when enrollment.blank?
      false
    when enrollment.free_trial?
      !enrollment.free_trial_expired?
    else
      true
    end
  end

  def completed_course?(course)
    self.badges.include?(course.badge)
  end

  def last_viewed_activity_in_assembly(assembly)
    child_ids = assembly.leaf_activities.map(&:id)
    last_activity = self.events.where(group_type: 'activity_show').where(trackable_id: child_ids).last
    if last_activity
      last_activity.trackable
    end
  end

  def class_enrollment(assembly)
    enrollments.where(enrollable_id: assembly.id, enrollable_type: assembly.class).first
  end

  def disconnect_service!(service)
    case service
    when "facebook"
      update_attributes({facebook_user_id: nil, provider: nil}, without_protection: true)
    when "google"
      update_attributes({google_user_id: nil, google_access_token: nil}, without_protection: true)
    when "twitter"
    else
      raise "Don't Recognize this service! Service was '#{service}'"
    end
  end

  def encrypted_bloom_info
    user_json = {'userId' => self.id.to_s}.to_json
    begin
      response = Faraday.get 'https://ancient-sea-7316.herokuapp.com/encrypt?string=' + user_json + '&secret=ilovesousvideYgpsagNPdJ&apiKey=xchefsteps'
      puts "This is the auth for bloom: #{response.body}"
      response.body
    rescue Faraday::Error::ConnectionFailed => e
      logger.warn "Unable to encrypt info for Bloom: #{e}"
    end
  end

  def as_indexed_json(options={})
    as_json(
      only: [:name, :bio]
    )
  end

  def self.with_views_greater_than(view_count)
    user_count = User.joins(:events).select('events.user_id').group('events.user_id').having("count(events.id) >=#{view_count}").count
    user_ids = user_count.keys
    users = User.find(user_ids)
    users
  end

  def self.export_top_users
    data = []
    users = User.with_views_greater_than(500).first(100)
    users.each do |user|
      unless (user.email.include? "@chefsteps.com") || (user.email.include? "desunaito@gmail.com")
        data << user.email
        puts "Importing user:"
        puts user
      end
    end
    open('///Users/hnguyen/Desktop/most_active_users', 'w') do |f|
      f << data.to_json
    end
  end
  def self.export_top_users_2
    data = []
    users = User.with_views_greater_than(500).last(500)
    users.each do |user|
      unless (user.email.include? "@chefsteps.com") || (user.email.include? "desunaito@gmail.com")
        data << user.email
        puts "Importing user:"
        puts user
      end
    end
    open('///Users/hnguyen/Desktop/most_active_users_2', 'w') do |f|
      f << data.to_json
    end
  end
end
