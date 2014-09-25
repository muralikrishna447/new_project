class EnrollmentSerializer < ApplicationSerializer
  attributes :id, :course_id, :user_id
  
  has_one :user
  has_one :enrollable
end
