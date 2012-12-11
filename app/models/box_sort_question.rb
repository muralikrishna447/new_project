class BoxSortQuestion < Question
  serialize :contents, BoxSortQuestionContents

  has_many :images

  def update_from_params(params)
    update_contents(params)
    save!
  end
end

