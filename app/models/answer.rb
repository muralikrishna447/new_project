class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user

  validates_uniqueness_of :question_id, scope: [:user_id]
  validates_presence_of :question_id
  validates_presence_of :user_id
  validates_presence_of :contents
end
