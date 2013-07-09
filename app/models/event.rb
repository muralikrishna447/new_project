class Event < ActiveRecord::Base
  attr_accessible :action, :user_id, :trackable

  belongs_to :user
  belongs_to :trackable, polymorphic: true

  default_scope order('created_at DESC')
  scope :timeline, where('action <> ?', 'show')

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
end
