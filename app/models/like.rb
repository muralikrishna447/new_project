class Like < ActiveRecord::Base
  attr_accessible :likeable_id, :likeable_type, :user_id

  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: {scope: [:likeable_id, :likeable_type], message: 'can only like an item once.'}

  def self.scoped_by_type(type)
    self.where('likeable_type = ?', type)
  end

  def receiver
    likeable.user if likeable.class.method_defined?(:user)
  end
end
