class QuestionPresenter < Presenter
  def attributes
    { id: @model.id }.merge(@model.contents_json)
  end
end

