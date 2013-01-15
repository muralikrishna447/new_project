class MultipleChoiceQuestion < Question
  include Imageable

  serialize :contents, MultipleChoiceQuestionContents

  def update_from_params(params)
    update_image(params.delete(:image))
    super
  end

  def title
    contents.question.present? ? contents.question : 'N/A'
  end
end

