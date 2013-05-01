class Event < ActiveRecord::Base
  attr_accessible :action, :user_id, :trackable

  belongs_to :user
  belongs_to :trackable, polymorphic: true

  belongs_to :trackable_inclusion, foreign_key: :trackable_id, class_name: 'Inclusion', conditions: {events: {trackable_type: 'Inclusion'}}

  default_scope order('created_at DESC')
  scope :timeline, where('action <> ?', 'show')

  def self.scoped_by(trackable_type, action)
    symbolized_trackable_type = trackable_type.downcase.pluralize.to_sym
    joins("INNER JOIN #{symbolized_trackable_type} ON #{symbolized_trackable_type}.id = events.trackable_id").where(action: action)
  end
end
