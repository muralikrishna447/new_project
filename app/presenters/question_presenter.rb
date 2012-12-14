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
    add_image_attributes(attrs)
    attrs
  end

  private

  def add_image_attributes(attrs)
    add_image(attrs) if @model.has_image?
    add_images(attrs) if @model.has_images?
  end

  def add_image(attrs)
    attrs[:image] = ImagePresenter.new(@model.image).wrapped_attributes
  end

  def add_images(attrs)
    attrs[:images] = ImagePresenter.wrapped_collection(@model.images)
  end
end

