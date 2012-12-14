class MultipleChoiceQuestion < Question
  include Imageable

  serialize :contents, MultipleChoiceQuestionContents

  def update_from_params(params)
    update_image(params.delete(:image))
    update_contents(params)
    save!
  end

  def title
    if contents.question.present?
      contents.question
    else
      'N/A'
    end
  end
end

