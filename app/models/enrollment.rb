class Enrollment < ActiveRecord::Base
  attr_accessible :course_id, :user_id
  belongs_to :user
  belongs_to :course
  has_many :events, as: :trackable, dependent: :destroy

  validates :course_id, uniqueness: {scope: :user_id, message: 'can only be enrolled once per student.'}
end
