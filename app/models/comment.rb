class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true
  has_many :events, as: :trackable, dependent: :destroy

  validates :commentable_id, :commentable_type, :content, :user_id, presence: true

  default_scope { order('created_at ASC') }
  scope :as_reviews, -> { where("rating IS NOT ?", nil) }

  def receiver
    commentable.user if commentable.class.method_defined?(:user)
  end
end
