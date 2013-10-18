class Vote < ActiveRecord::Base
  attr_accessible :user_id, :votable_id, :votable_type

  belongs_to :user
  belongs_to :votable, polymorphic: true, counter_cache: true
  has_many :events, as: :trackable, dependent: :destroy

  validates :user_id, uniqueness: {scope: [:votable_id, :votable_type], message: 'can only vote on an item once.'}

  def self.scoped_by_type(type)
    self.where('votable_type = ?', type)
  end
end
