class Question < ActiveRecord::Base
  include RankedModel
  include SerializeableContents

  ranks :question_order, with_same: :quiz_id

  self.inheritance_column = :question_type

  belongs_to :quiz
  has_many :answers

  attr_accessible :quiz_id, :contents

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

  def score_answer(answer_data, user)
    answer = Answer.new_of_type(answer_data[:type])
    answer.question = self
    answer.user = user
    answer.update_contents(answer_data)
    answer.correct = contents.correct(answer_data)
    answer.save!
    answer
  end

  def answer_count
    answers.count
  end
end

