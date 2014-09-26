class EventSerializer < ApplicationSerializer
  attributes :id, :action, :trackable_id, :trackable_type, :group_type, :group_name, :created_at, :user, :event_type

  has_one :trackable, polymorphic: true

  def event_type
    object.event_type
  end
end
