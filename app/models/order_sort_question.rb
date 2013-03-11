class OrderSortQuestion < Question
  serialize :contents, OrderSortQuestionContents

  has_many :images,
           class_name: 'OrderSortImage',
           foreign_key: 'question_id',
           dependent: :destroy

  delegate :question,
           :instructions,
           :solutions,
           :options,
           to: :contents,
           allow_nil: true

  def score(answer)
    answer.contents.solution_score = self.contents.solution_score(answer.contents)
    answer.contents.best_solution = self.contents.best_solution(answer.contents)
    super
  end
end
