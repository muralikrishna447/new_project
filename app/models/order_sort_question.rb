class OrderSortQuestion < Question
  serialize :contents, OrderSortQuestionContents

  has_many :images,
           class_name: 'OrderSortImage',
           foreign_key: 'question_id',
           dependent: :destroy
end
