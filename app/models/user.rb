class User < ApplicationRecord
  has_merit

  include User::Google
  include User::Facebook
  include User::Apple
  include Gravtastic
  include UpdateWhitelistAttributes
  extend FriendlyId

  friendly_id :name, use: :slugged

  CHEF_TYPES = %w[professional_chef culinary_student home_cook novice other]

  include ActsAsSanitized
  sanitize_input :bio, :name, :location, :website

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
  has_many :owned_circulators, -> { where('circulator_users.owner =?', true) }, source: :circulator, through: :circulator_users

  has_many :actor_addresses, as: :actor

  has_many :joule_cook_history_items

  has_many :tf2_redemptions

  has_many :oauth_tokens

  has_one :settings, class_name: 'UserSettings', :dependent => :destroy

  has_many :subscriptions, :dependent => :destroy

  serialize :viewed_activities, Array

  scope :where_any, ->(column, key, value) { where("? LIKE ANY (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }
  scope :where_all, ->(column, key, value) { where("? LIKE ALL (SELECT UNNEST(string_to_array(\"#{column}\",',')) -> ?)", '%' + value + '%', key) }

  gravtastic

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :token_authenticatable, :omniauth_providers => [:google_oauth2]

  attr_accessor :skip_name_validation

  validates_presence_of :name, unless: Proc.new {|user| user.skip_name_validation == true}

  validates_inclusion_of :chef_type, in: CHEF_TYPES, allow_blank: true

  serialize :survey_results, ActiveRecord::Coders::NestedHstore

  ROLES = %w[admin contractor moderator collaborator user banned]

  WHITELIST_ATTRIBUTES = [:name, :email, :password, :password_confirmation,
                         :remember_me, :location, :quote, :website, :chef_type, :from_aweber,
                          :viewed_activities, :signed_up_from, :bio, :image_id, :referred_from,
                          :referrer_id, :survey_results, :events_count]

  def settings_hash
    return {} if self.settings.nil?
    UserSettings::API_FIELDS.reduce({}) do |h, key|
      h[key] = self.settings[key]
      h
    end
  end

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

  def studio?
    Subscription::user_has_studio?(self)
  end

  def cancelled_studio?
    Subscription.user_has_cancelled_studio?(self)
  end

  # This method indicates whether the user has the Premium capability and
  # is allowed to access Premium features. It does not directly indicate
  # whether someone has purchased or received a Premium membership. Use
  # premium_member? for that.
  def premium?
    self.premium_member || admin || self.studio?
  end

  # Indicates whether a user has purchased or otherwise received a Premium
  # membership.
  def premium_member?
    self.premium_member
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

  def make_premium_member(price, send_welcome_email = false)
    # Not an error b/c we do this on both main and worker, can be
    # racing each other.
    return if self.premium_member?

    self.premium_member = true
    self.premium_membership_created_at = DateTime.now
    self.premium_membership_price = price
    # There are users that already don't pass validation so can't be resaved; not fixing right now
    self.save(validate: false)
    Resque.enqueue(UserSync, self.id)

    if send_welcome_email
      PremiumWelcomeMailer.prepare(self).deliver
    end
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
    enrollments.where('enrollable_id= ? and enrollable_type =?', assembly.id, assembly.class).first
  end

  def disconnect_service!(service)
    case service
    when "facebook"
      update_attributes({facebook_user_id: nil, provider: nil})
    when "google"
      update_attributes({google_user_id: nil, google_access_token: nil})
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
    rescue Faraday::TimeoutError => e
      logger.warn "Unable to encrypt info for Bloom: #{e}"
      return ''
    rescue Faraday::ConnectionFailed => e
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

  def create_restricted_token(restriction, expires_in_time)
    aa = ActorAddress.create_for_user(self, client_metadata: restriction)
    exp = ((Time.now + expires_in_time).to_f * 1000).to_i
    aa.current_token(exp: exp, restrict_to: restriction)
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
    User.transaction do
      update_attribute(:deleted_at, Time.current)
      ActorAddress.revoke_all_for_user(self)
    end
  end

  def undelete
    logger.info "Setting User #{id} as undeleted at #{Time.current}"
    update_attribute(:deleted_at, nil)
  end

  # Overwriting destroy/delete methods to have them perform the soft delete.
  # This should make actually deleting a user impossible.
  def destroy
    logger.warn "Something called destroy on User #{id} at #{Time.current}.  Soft Deleting instead."
    soft_delete
  end

  def delete
    logger.warn "Something called delete on User #{id} at #{Time.current}.  Soft Deleting instead."
    soft_delete
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
    logger.info("Merging user with id #{user_to_merge.id} into user with id #{id}: merging #{user_to_merge.inspect} to #{inspect}")
    User.transaction do
      merge_properties(user_to_merge)
      merge_premium(user_to_merge)
      merge_relations(user_to_merge)
      save!
      user_to_merge.soft_delete
    end
    logger.info("Merge completed for user with id #{id}: #{inspect}")
    rescue Exception => e
      logger.error("Merge failed for user with id #{id}, transaction was rolled back: #{e.message}")
      raise e
  end

  # For tf2 redemption codes
  def max_tf2_redemptions
    owned_joules = self.owned_circulators.count
    purchased_joules = self.joule_purchase_count
    owned_joules > purchased_joules ? owned_joules : purchased_joules
  end

  # For tf2 redemption codes
  def can_do_tf2_redemption?
    current_redemptions = self.tf2_redemptions.count
    current_redemptions < max_tf2_redemptions
  end

  def send_password_reset_email
    logger.info "Sending password reset email for: #{self.email}"
    aa = ActorAddress.create_for_user self, client_metadata: "password_reset"
    exp = ((Time.now + 1.day).to_f * 1000).to_i
    token = aa.current_token(exp: exp, restrict_to: 'password reset').to_jwt
    UserMailer.reset_password(self.email, token).deliver_now
  end

  def capabilities
    # Hardcoding the list of possible capabilities for now.
    capability_list = [
        'turbo',
        'autostart',
        'joule_ready',
        'beta_guides',
        'update_during_pairing',
        'app_review_prompts',
    ]
    cache_key = "user-capabilities-#{id}"
    user_capabilities = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      user_groups_cache = BetaFeatureService.get_groups_for_user(self)
      capability_list.select {|c|
        BetaFeatureService.user_has_feature(self, c, user_groups_cache)
      }
    end

    user_capabilities
  end

  private

  def merge_properties(user_to_merge)
    merge_if_blank(
      user_to_merge,
      [
        :name, :location, :quote, :website, :chef_type, :from_aweber,
        :signed_up_from, :bio, :image_id, :referred_from, :skip_name_validation,
        :survey_results, :viewed_activities
      ]
    )
    self.role = user_to_merge.role unless role?(user_to_merge.role)
    self.referrer_id = user_to_merge.referrer_id unless referrer_id
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
      logger.info("Merged user with id #{user_to_merge.id} is premium, adding premium to user with id #{id}")
      self.premium_member = true
      self.premium_membership_price = user_to_merge.premium_membership_price
      self.premium_membership_created_at = user_to_merge.premium_membership_created_at
    end
  end

  def merge_relations(user_to_merge)
    Upload.where(user_id: user_to_merge.id).update_all(user_id: id)
    Event.where(user_id: user_to_merge.id).update_all(user_id: id)
    Activity.where('creator =?', user_to_merge.id).update_all(creator: id)
    PremiumGiftCertificate.where(purchaser_id: user_to_merge.id).update_all(purchaser_id: id)
    merge_likes(user_to_merge)
    merge_circulator_users(user_to_merge)
  end

  def merge_likes(user_to_merge)
    likeable_ids = likes.map(&:likeable_id)
    if likeable_ids.empty?
      likes_to_merge = user_to_merge.likes
    else
      # Only merge likes on things not already liked by self
      likes_to_merge = Like.where('user_id = ? AND likeable_id NOT IN (?)', user_to_merge.id, likeable_ids)
    end
    likes_to_merge.update_all(user_id: id)
  end

  def merge_circulator_users(user_to_merge)
    circulator_ids = circulator_users.map(&:circulator_id)
    if circulator_ids.empty?
      circulator_users_to_merge = user_to_merge.circulator_users
    else
      # Only merge circulator_user entries that aren't already on self
      circulator_users_to_merge = CirculatorUser.where('user_id = ? AND circulator_id NOT IN (?)', user_to_merge.id, circulator_ids)
    end
    logger.info("Merging circulator users into user with id #{id}: #{circulator_users_to_merge.inspect}")
    circulator_users_to_merge.update_all(user_id: id)
  end

  def self.fetchCount
    Rails.cache.fetch("userCount", expires_in: 1.hour){
      User.count
    }
  end

end
