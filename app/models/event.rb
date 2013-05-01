class Event < ActiveRecord::Base
  attr_accessible :action, :user_id, :trackable

  belongs_to :user
  belongs_to :trackable, polymorphic: true

  default_scope order('created_at DESC')
  scope :timeline, where('action <> ?', 'show')
end
