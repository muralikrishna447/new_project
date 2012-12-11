class BoxSortQuestion < Question
  serialize :contents, BoxSortQuestionContents

  has_many :images, class_name: 'BoxSortImage', foreign_key: 'question_id'

  def update_from_params(params)
    update_contents(params)
    save!
  end
end

