class Enrollment < ActiveRecord::Base
  attr_accessible :course_id, :user_id, :enrollable
  belongs_to :user
  # belongs_to :course
  belongs_to :enrollable, polymorphic: true
  has_many :events, as: :trackable, dependent: :destroy

  # validates :course_id, uniqueness: {scope: :user_id, message: 'can only be enrolled once per student.'}
  validates :enrollable_id, uniqueness: {scope: [:user_id, :enrollable_type], message: 'can only be enrolled once per student.'}

  def self.exists_for(user,enrollable)
    enrollment = Enrollment.where(user_id: user.id, enrollable_type: enrollable.class.to_s, enrollable_id: enrollable.id)
    enrollment.blank? ? false : true
  end
end
