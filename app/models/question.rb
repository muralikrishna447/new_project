class Question < ActiveRecord::Base
  include RankedModel
  include SerializeableContents
  include Imageable

  ranks :question_order, with_same: :quiz_id

  belongs_to :quiz
  has_many :answers

  attr_accessible :quiz_id, :contents

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

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
end

