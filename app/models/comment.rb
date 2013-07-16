class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content, :user_id
  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true

  validates :commentable_id, :commentable_type, :content, :user_id, presence: true

  default_scope order('created_at ASC')

  def receiver
    commentable.user if commentable.class.method_defined?(:user)
  end
end
