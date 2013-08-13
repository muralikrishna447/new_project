class EventSerializer < ActiveModel::Serializer
  attributes :id, :action, :trackable_id, :trackable_type, :group_type, :group_name, :created_at, :user

  has_one :trackable, polymorphic: true
end
