class QuestionPresenter < Presenter
  def attributes
    {
      id: @model.id
    }
  end
end
