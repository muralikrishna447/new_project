class QuestionPresenter < Presenter
  def initialize(model, admin=false)
    @admin = admin
    super(model)
  end

  def attributes
    attrs = {
      id: @model.id,
      question_type: @model.symbolize_question_type
    }.merge(@model.contents_json(@admin))
    attrs[:image] = ImagePresenter.new(@model.image).wrapped_attributes if @model.image.present?
    attrs
  end
end

