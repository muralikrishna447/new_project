class Quiz < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  friendly_id :title, use: :slugged

  belongs_to :activity

  has_many :questions
  has_many :images, class_name: "QuizImage"
  has_one :image, as: :imageable

  attr_accessible :title, :activity_id, :start_copy, :end_copy

  def add_multiple_choice_question
    question = MultipleChoiceQuestion.create
    questions << question
    question
  end

  def question_count
    questions.count
  end

  def ordered_questions
    questions.ordered
  end

  def update_question_order(question_ids)
    question_ids.each do |question_id|
      questions.find(question_id).update_attribute(:question_order_position, :last)
    end
  end

  def questions_answered_by(user)
    ordered_questions.joins(:answers).where(answers: {user_id: user.id})
  end

  def questions_remaining_for(user)
    ordered_questions - questions_answered_by(user)
  end

  def questions_answered_by_count(user)
    questions_answered_by(user).count
  end

  def questions_remaining_for_count(user)
    questions_remaining_for(user).count
  end

  def started_by?(user)
    questions_answered_by_count(user) > 0
  end

  def completed_by?(user)
    questions_remaining_for_count(user) == 0
  end
end
