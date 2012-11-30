class QuestionPresenter < Presenter
  def attributes
    { id: @model.id }.merge(@model.contents.marshal_dump)
  end
end

