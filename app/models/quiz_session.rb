class QuizSession < ActiveRecord::Base
  belongs_to :user, inverse_of: :quizzes
  belongs_to :quiz, inverse_of: :quiz_sessions

  attr_accessible :quiz_id, :user_id, :completed

  scope :completed, where(completed: true)

end

