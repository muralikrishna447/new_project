class QuestionPresenter < Presenter
  def attributes
    {
      id: @model.id,
      title: @model.title
    }
  end
end
