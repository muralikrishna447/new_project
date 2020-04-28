class Event < ActiveRecord::Base

  belongs_to :user, counter_cache: true
  belongs_to :trackable, polymorphic: true

  # default_scope includes(:user).order('created_at DESC')
  scope :timeline, -> { where('action <> ?', 'show').order('created_at DESC')  }
  scope :unviewed, -> { where(viewed: false) }
  scope :published, -> { where(published: true) }

  validates_presence_of :trackable_id, :trackable_type, :action

  after_create :save_group_type_and_group_name

  def self.scoped_by(trackable_type, action)
    # Returns a set of events by trackable type and action
    # example 1: Event.scoped_by('Inclusion', 'show') returns all events where any user viewed a activity inside a course
    # example 2: current_user.events.scoped_by('Upload', 'create') returns events where the current user uploaded a photo
    symbolized_trackable_type = trackable_type.downcase.pluralize.to_sym
    results = joins("INNER JOIN #{symbolized_trackable_type} ON #{symbolized_trackable_type}.id = events.trackable_id").where(trackable_type: trackable_type).where(action: action)
    results
  end

  def receiver
    trackable.receiver if trackable.class.method_defined?(:receiver)
  end

  def event_type
    [trackable_type, action].join('_').downcase
  end

  def determine_group_type
    [trackable_type, action].join('_').downcase
  end

  def determine_group_name
    # This generates the group name for the event to group similar items for the activity stream
    # Should run rake generate_group_name_and_type to update past events if this code changes
    case [trackable_type, action]
    when ['Activity', 'create']
      [trackable_type, trackable_id, action, "user_#{user_id}"].join('_').downcase
    # when ['Activity', 'show']
    #   [trackable_type, trackable_id, action].join('_').downcase
    when ['Comment','create']
      [trackable_type, trackable_id, action, trackable.commentable_type, trackable.commentable_id, "user_#{user_id}"].join('_').downcase
      # "Comment_#{trackable_id}_created_for_#{trackable.commentable_type}_#{trackable.commentable_id}"
    when ['Comment','received_create']
      [trackable_type, trackable_id, action, trackable.commentable_type, trackable.commentable_id, "user_#{user_id}"].join('_').downcase
    when ['Course','enroll']
      [trackable_type, trackable_id, action, created_at.end_of_day.to_s(:number)].join('_').downcase
    when ['Enrollment', 'create']
      [trackable_type, trackable_id, action, created_at.end_of_day.to_s(:number)].join('_').downcase
    when ['Inclusion', 'show']
      trackable ? [trackable_type, trackable_id, action].join('_').downcase : nil
    when ['Like','create']
      [trackable_type, trackable_id, action, trackable.likeable_type, trackable.likeable_id, "user_#{user_id}"].join('_').downcase
    when ['Like','received_create']
      [trackable_type, trackable_id, action, trackable.likeable_type, trackable.likeable_id, "user_#{user_id}"].join('_').downcase
    when ['Upload', 'create']
      [trackable_type, trackable_id, action].join('_').downcase
    when ['Vote', 'create']
      if trackable
        [trackable_type, action, trackable.votable_type, trackable.votable_id, "poll_#{trackable.votable.poll.id}", created_at.end_of_day.to_s(:number)].join('_').downcase
      else
        nil
      end
    else
      nil
    end
    # [type,name]
  end

  def determine_published
    case [trackable_type, action]
    when ['Activity', 'create']
      trackable.published ? true : false
    when ['Course', 'enroll']
      trackable.published ? true : false
    when ['Like', 'create']
      if trackable.likeable_type == 'Activity'
        trackable.likeable.published ? true : false
      else
        true
      end
    else
      true
    end
  end

  def save_group_type_and_group_name
    self.group_type = self.determine_group_type
    self.group_name = self.determine_group_name
    self.published = self.determine_published
    self.save
  end

end
