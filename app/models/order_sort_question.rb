class OrderSortQuestion < Question
  serialize :contents, OrderSortQuestionContents

  has_many :images,
           class_name: 'OrderSortImage',
           foreign_key: 'question_id',
           dependent: :destroy

  delegate :instructions,
           :options,
           to: :contents,
           allow_nil: true
end
