class BoxSortQuestion < Question
  serialize :contents, BoxSortQuestionContents

  def update_from_params(params)
    update_contents(params)
    save!
  end

  def instructions
    contents.instructions || default_instructions
  end

  def default_instructions
    "Please drag and drop the following images into one of the three piles based on which images you remember seeing in the course you've just completed."
  end
end

