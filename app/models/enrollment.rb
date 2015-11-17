class Enrollment < ActiveRecord::Base

  attr_accessible :user_id, :enrollable
  belongs_to :user
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy

  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

end
