class Question < ActiveRecord::Base
  include RankedModel

  ranks :question_order, with_same: :quiz_id

  self.inheritance_column = :question_type

  belongs_to :quiz
  has_many :answers

  attr_accessible :quiz_id, :contents

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

  def update_contents(params)
    self.contents.update(params)
  end

  def contents_json(admin)
    self.contents.to_json(admin)
  end

  def score_answer(answer_data, user)
    answer = answers.build
    answer.user = user
    answer.contents = answer_data
    answer.correct = contents.correct(answer_data)
    answer.save!
    answer
  end

  def answer_count
    answers.count
  end

  private
  def init_contents
    return if persisted?
    self.contents = contents_class.new({}) if self.contents.blank?
  end

  def contents_class
    (self.class.name.to_s + 'Contents').constantize
  end
end

