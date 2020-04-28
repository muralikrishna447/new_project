class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: true

  has_many :events, as: :trackable, dependent: :destroy

  validates :user_id, presence: true
  validates :user_id, uniqueness: {scope: [:likeable_id, :likeable_type], message: 'can only like an item once.'}

  default_scope { includes(:user).order('created_at DESC') }

  def self.scoped_by_type(type)
    self.where('likeable_type = ?', type)
  end

  def receiver
    likeable.user if likeable.class.method_defined?(:user)
  end
end
