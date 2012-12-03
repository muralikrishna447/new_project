class QuestionPresenter < Presenter
  def initialize(model, admin=false)
    @admin = admin
    super(model)
  end

  def attributes
    { id: @model.id }.merge(@model.contents_json(@admin))
  end
end

