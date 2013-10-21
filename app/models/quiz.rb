class Quiz < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  include Imageable

  friendly_id :title, use: :slugged

  belongs_to :activity

  has_many :questions

  has_many :quiz_sessions, dependent: :destroy, inverse_of: :quiz

  attr_accessible :title, :activity_id, :start_copy, :end_copy, :image_attributes
  accepts_nested_attributes_for :image, allow_destroy: true

  def add_question(question_type)
    question = question_class_from_type(question_type).create
    questions << question
    question.update_order(:last)
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
      questions.find(question_id).update_order(:last)
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
    question_count > 0 && questions_remaining_for_count(user) == 0
  end

  def destroy_answers_for(user)
    questions.each do |question|
      answer = question.answer_for(user)
      answer.destroy
    end
  end

  def started_count
    ordered_questions.first.answer_count
  end

  def completed_count
    ordered_questions.last.answer_count
  end

  def has_image?
    image? && image.url?
  end

  comma :report do
    title
    started_count "Users Started"
    completed_count "Users Completed"
    question_count "Questions"
  end

  private

  def question_class_from_type(question_type)
    question_type.to_s.classify.constantize
  end

end

