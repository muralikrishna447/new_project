class MultipleChoiceQuestion < Question
  serialize :contents, MultipleChoiceQuestionContents

  has_one :image, as: :imageable
end
