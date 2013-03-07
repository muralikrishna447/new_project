class Question < ActiveRecord::Base
  include RankedModel
  include SerializeableContents

  ranks :question_order, with_same: :quiz_id

  belongs_to :quiz
  has_many :answers

  attr_accessible :quiz_id, :contents

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

  comma :report do
    title
    average_correct "Average"
    answer_count "Answered"
  end

  ##
  # These methods are expected to be implemented in any subclass:
  ##
  def instructions
    raise NotImplementedError, "#instructions should be implemented in #{self.class}"
  end

  def options
    raise NotImplementedError, "#options should be implemented in #{self.class}"
  end

  def update_from_params(params)
    update_contents(params)
    save!
  end

  def title
    type
  end

  def ordered_images
    images.ordered
  end

  def score(answer)
    answer.question = self
    answer.correct = correct(answer)

    answer.save!
    answer
  end

  def correct(answer)
    self.contents.correct(answer.contents)
  end

  def answer_count
    answers.count
  end

  def answer_for(user)
    answers.find_by_user_id(user)
  end

  def average_correct
    return '-' if answer_count.zero?
    (correct_answer_count.to_f / answer_count * 100).to_i
  end

  def symbolize_question_type
    type.underscore.chomp('_question').to_sym
  end

  def has_image?
    begin
      image.present?
    rescue
      false
    end
  end

  def has_images?
    begin
      images.present?
    rescue
      false
    end
  end

  def update_order(position)
    type = self.type
    self.becomes(Question).update_attributes({question_order_position: position, type: type}, without_protection: true)
  end
end

