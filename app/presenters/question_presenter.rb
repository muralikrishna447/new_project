class QuestionPresenter < Presenter
  def attributes
    { id: @model.id,
      question_order: @model.question_order
    }.merge(@model.contents.marshal_dump)
  end
end

