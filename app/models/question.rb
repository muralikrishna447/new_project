class Question < ActiveRecord::Base
  include RankedModel
  include SerializeableContents
  include Imageable

  ranks :question_order, with_same: :quiz_id

  self.inheritance_column = :question_type

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
    answers.where(user_id: user).first
  end

  def average_correct
    (correct_answer_count.to_f / answer_count * 100).to_i
  end
end

