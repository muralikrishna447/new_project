class QuestionPresenter < Presenter
  def present
    HashWithIndifferentAccess.new({
      id: @model.id
    }).to_json
  end
end
