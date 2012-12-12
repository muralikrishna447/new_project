class BoxSortQuestion < Question
  serialize :contents, BoxSortQuestionContents

  has_many :images, class_name: 'BoxSortImage', foreign_key: 'question_id'

  def update_from_params(params)
    update_contents(params)
    save!
  end

  def instructions
    contents.instructions || default_instructions
  end

  def options
    contents.options || default_options
  end

  def default_instructions
    "Please <strong>drag and drop</strong> the following images into one of the three piles based on which images you remember seeing in the course you've just completed."
  end

  def default_options
    [{
      text: "I remember"
    },{
      text: "I'm not sure"
    },{
      text: "I don't remember"
    }]
  end
end

