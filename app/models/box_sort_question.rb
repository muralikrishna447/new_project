class BoxSortQuestion < Question
  serialize :contents, BoxSortQuestionContents

  def update_from_params(params)
    update_contents(params)
    save!
  end
end

