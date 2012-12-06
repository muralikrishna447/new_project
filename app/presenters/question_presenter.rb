class QuestionPresenter < Presenter
  def initialize(model, admin=false)
    @admin = admin
    super(model)
  end

  def attributes
    attrs = { id: @model.id }.merge(@model.contents_json(@admin))
    attrs[:image] = ImagePresenter.new(@model.image).present if @model.image.present?
    attrs
  end
end

