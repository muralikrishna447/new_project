class Answer < ActiveRecord::Base
  include SerializeableContents

  ANSWER_TYPES = [:multiple_choice]

  belongs_to :question, counter_cache: :answer_count
  belongs_to :user

  after_save :update_question_statistics

  validates_uniqueness_of :question_id, scope: [:user_id]
  validates_presence_of :question_id
  validates_presence_of :user_id
  validates_presence_of :contents

  def self.new_of_type(type, attributes = {})
    type_valid = ANSWER_TYPES.include?(type.to_sym)
    type_valid ? answer_class(type).new(attributes) : nil
  end

  private

  def self.answer_class(type)
    "#{type}_answer".camelcase.constantize
  end

  def update_question_statistics
    return if self.question.nil?
    self.question.correct_answer_count += 1 if self.correct?
    self.question.incorrect_answer_count += 1 unless self.correct?
    self.question.save
  end
end
