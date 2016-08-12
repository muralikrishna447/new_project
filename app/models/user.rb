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
  has_many :owned_circulators, source: :circulator, through: :circulator_users, conditions: ["circulator_users.owner = ?", true]

  has_many :actor_addresses, as: :actor

  serialize :viewed_activities, Array

  scope :where_any, ->(column, key, value) { where("? LIKE ANY (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }
  scope :where_all, ->(column, key, value) { where("? LIKE ALL (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable, :omniauth_providers => [:google_oauth2]

  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id, :referred_from, :referrer_id, :survey_results, :events_count

  # This is for active admin, so that it can edit the role (and so normal users can't edit their role)
  attr_accessible :name, :email, :password, :password_confirmation,
    :remember_me, :location, :quote, :website, :chef_type, :from_aweber, :viewed_activities, :signed_up_from, :bio, :image_id, :role, :referred_from, :referrer_id, :premium_member, :premium_membership_created_at, :premium_membership_price, as: :admin

  attr_accessor :skip_name_validation

  validates_presence_of :name, unless: Proc.new {|user| user.skip_name_validation == true}

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  serialize :survey_results, ActiveRecord::Coders::NestedHstore

  ROLES = %w[admin contractor moderator collaborator user banned]


  def role?(base_role)
    ROLES.index(base_role.to_s) >= ROLES.index(role)
  end

  def role
    read_attribute(:role) || "user"
  end

  def admin?
    self.role == "admin"
  end

  def admin
    self.admin?
  end

  def profile_complete?
    chef_type.present?
  end

  def premium?
    self.premium_member || admin
  end

  def viewed_activities_in_course(course)
    course.activities.joins(:events).where('events.user_id = ?', self.id).select{|a| a.published=true}.uniq
  end

  def last_viewed_activity_in_course(course)
    last_viewed = events.scoped_by('Activity', 'show').order('created_at asc').where(trackable_id: course.activity_ids).last
    if last_viewed
      last_viewed.trackable
    end
  end

  def likes_object?(likeable_object)
    Like.where('user_id = ? AND likeable_type = ? AND likeable_id = ?', self.id, likeable_object.class.to_s, likeable_object.id).any?
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
    if enrollable.nil?
      return false
    end

    enrollment = Enrollment.where(user_id: self.id, enrollable_type: enrollable.class.to_s, enrollable_id: enrollable.id).first
    case
    when enrollment.blank?
      false
    else
      true
    end
  end

  def make_premium_member(price)
    # Not an error b/c we do this on both main and worker, can be
    # racing each other.
    return if self.premium?

    self.premium_member = true
    self.premium_membership_created_at = DateTime.now
    self.premium_membership_price = price
    # There are users that already don't pass validation so can't be resaved; not fixing right now
    self.save(validate: false)
    Resque.enqueue(UserSync, self.id)
  end

  def remove_premium_membership
    self.premium_member = false
    self.premium_membership_created_at = nil
    self.premium_membership_price = nil
    # There are users that already don't pass validation so can't be resaved; not fixing right now
    self.save(validate: false)
    Resque.enqueue(UserSync, self.id)
  end

  def use_premium_discount
    self.used_circulator_discount = true
    self.save(validate: false)
  end

  def joule_purchased
    if first_joule_purchased_at.blank?
      self.update_attribute(:first_joule_purchased_at, Time.now)
    end
    self.increment!(:joule_purchase_count)
  end

  def can_receive_circulator_discount?
    premium_member && !used_circulator_discount
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
      response = Faraday.get do |req|
        req.url "#{Rails.application.config.shared_config[:bloom][:api_endpoint]}/encrypt?string=" + user_json + '&secret=ilovesousvideYgpsagNPdJ&apiKey=xchefsteps'
        req.options[:timeout] = 3
        req.options[:open_timeout] = 2
      end
      puts "This is the auth for bloom: #{response.body}"
      response.body
    rescue Faraday::Error::TimeoutError => e
      logger.warn "Unable to encrypt info for Bloom: #{e}"
      return ''
    rescue Faraday::Error::ConnectionFailed => e
      logger.warn "Unable to encrypt info for Bloom: #{e}"
      return ''
    end
  end

  def valid_website_auth_token
    aa = ActorAddress.find_for_user_and_unique_key(self, 'website')
    if aa
      Rails.logger.info "[auth] found existing website actor address #{aa.id} for user #{self.id}." if aa
    else
      Rails.logger.info "[auth] creating new website actor address for user #{self.id}"
      begin
        aa = ActorAddress.create_for_user(self, {unique_key: 'website'})
      rescue ActiveRecord::RecordNotUnique
        Rails.logger.info("[auth] Failed to create uplicate actor address")
        aa = ActorAddress.find_for_user_and_unique_key(self, 'website')
      end
    end
    unless aa
      msg = "Failed to find actor address event after unique key conflict"
      Rails.logger.warn("[auth] - #{msg}")
      raise msg
    end

    aa.current_token(exp: 365.days.from_now.to_i)
  end

  def was_shown_terms
    self.update_attribute(:needs_special_terms, false)
  end

  def remember_token
    if needs_special_terms
      token = SecureRandom.base64
    # Remaining conditional copied verbatim from rememberable.rb
    elsif respond_to?(:authenticatable_salt) && (salt = authenticatable_salt)
      token = salt
    else
      raise "authenticable_salt returned nil for the #{self.class.name} model. " \
        "In order to use rememberable, you must ensure a password is always set " \
        "or have a remember_token column in your model or implement your own " \
        "rememberable_value in the model with custom logic."
    end

    logger.info "[auth] User [#{self.id}] special terms [#{needs_special_terms}] using remember_token value #{token}"
    return token
  end

  def generate_remember_token?
    logger.info "[auth] Returning false for generate remember token"
    return false
  end

  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    logger.info "Setting User #{id} as soft deleted at #{Time.current}"
    update_attribute(:deleted_at, Time.current)
  end

  def undelete
    logger.info "Setting User #{id} as undeleted at #{Time.current}"
    update_attribute(:deleted_at, nil)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  # provide a custom message for a deleted account
  def inactive_message
    !deleted_at ? super : "Your account has been deleted."
  end

  def merge(user_to_merge)
    User.transaction do
      merge_properties(user_to_merge)
      merge_premium(user_to_merge)
      merge_relations(user_to_merge)
      save
      # TODO handle validation failures
      # TODO soft delete
    end
  end

  private

  def merge_properties(user_to_merge)
    merge_if_blank(
      user_to_merge,
      [
        :name, :location, :quote, :website, :chef_type, :from_aweber,
        :signed_up_from, :bio, :image_id, :referred_from, :skip_name_validation
      ]
    )
    self.role = user_to_merge.role unless role?(user_to_merge.role)
    self.referrer_id = user_to_merge.referrer_id unless referrer_id
    self.survey_results = user_to_merge.survey_results if survey_results.empty?
  end

  def merge_if_blank(user_to_merge, props)
    props.each do |prop|
      self_value = send(prop)
      user_to_merge_value = user_to_merge.send(prop)
      send("#{prop}=", user_to_merge_value) if self_value.blank?
    end
  end

  def merge_premium(user_to_merge)
    if !premium_member && user_to_merge.premium_member
      self.premium_member = true
      self.premium_membership_price = user_to_merge.premium_membership_price
      self.premium_membership_created_at = DateTime.now
    end
  end

  def merge_relations(user_to_merge)
    Upload.where(user_id: user_to_merge.id).update_all(user_id: id)
    Event.where(user_id: user_to_merge.id).update_all(user_id: id)
    Activity.where(creator: user_to_merge.id).update_all(creator: id)
    merge_likes(user_to_merge)
  end

  def merge_likes(user_to_merge)
    likeable_ids = likes.map(&:likeable_id)
    if likeable_ids.empty?
      likes_to_merge = Like.where(user_id: user_to_merge.id)
    else
      # Only merge likes on things not already liked by self
      likes_to_merge = Like.where('user_id = ? AND likeable_id NOT IN (?)', user_to_merge.id, likeable_ids)
    end
    likes_to_merge.update_all(user_id: id)
  end
end
