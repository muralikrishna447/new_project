class Event < ActiveRecord::Base
  attr_accessible :action, :user_id, :trackable, :viewed

  belongs_to :user
  belongs_to :trackable, polymorphic: true

  default_scope order('created_at DESC')
  scope :timeline, where('action <> ?', 'show')
  scope :unviewed, where(viewed: false)

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

  def group_name
    # This generates the group name for the event to group similar items for the activity stream
    type = [trackable_type, action]
    case type
    when ['Comment','create']
      name = [trackable_type, trackable_id, action, trackable.commentable_type, trackable.commentable_id].join('_')
      # "Comment_#{trackable_id}_created_for_#{trackable.commentable_type}_#{trackable.commentable_id}"
    when ['Comment','received_create']
      name = [trackable_type, trackable_id, action, trackable.commentable_type, trackable.commentable_id].join('_')
    when ['Course','enroll']
      name = [trackable_type, trackable_id, action].join('_')
    when ['Like','create']
      name = [trackable_type, action, trackable.likeable_type, trackable.likeable_id].join('_')
    when ['Like','received_create']
      name = [trackable_type, action, trackable.likeable_type, trackable.likeable_id].join('_')
    when ['Upload', 'create']
      name = [trackable_type, trackable_id, action].join('_')
    else
      self.inspect
    end
    [type,name]
  end

end
