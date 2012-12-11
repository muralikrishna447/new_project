class MultipleChoiceQuestion < Question
  serialize :contents, MultipleChoiceQuestionContents

  def update_from_params(params)
    update_image(params.delete(:image))
    update_contents(params)
    save!
  end
end

