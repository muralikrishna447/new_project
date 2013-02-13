class Answer < ActiveRecord::Base
  include SerializeableContents

  ANSWER_TYPES = [:multiple_choice, :box_sort, :order_sort]

  belongs_to :question, counter_cache: :answer_count
  belongs_to :user

  after_save :increment_question_statistics
  before_destroy :decrement_question_statistics

  validates_uniqueness_of :question_id, scope: [:user_id]
  validates_presence_of :question_id
  validates_presence_of :user_id
  validates_presence_of :contents

  def self.new_from_params(params, user)
    type = params.delete(:type).to_sym
    return nil unless ANSWER_TYPES.include?(type)
    answer_class(type).new.tap do |answer|
      answer.user = user
      answer.update_contents(params)
    end
  end

  private

  def self.answer_class(type)
    "#{type}_answer".camelcase.constantize
  end

  def increment_question_statistics
    return if self.question.nil?
    self.question.correct_answer_count += 1 if self.correct?
    self.question.incorrect_answer_count += 1 unless self.correct?
    self.question.save
  end

  def decrement_question_statistics
    return if self.question.nil?
    self.question.correct_answer_count -= 1 if self.correct?
    self.question.incorrect_answer_count -= 1 unless self.correct?
    self.question.save
  end
end
