class ImagePresenter < Presenter
  def attributes
    attrs = {
      id: @model.id,
      filename: @model.filename,
      caption: @model.caption,
      url: @model.url
    }
    extend_attributes(attrs)
    attrs
  end

  private

  def extend_attributes(attrs)
    if @model.instance_of?(BoxSortImage)
      attrs.merge!({
        key_image: @model.key_image,
        key_explanation: @model.key_explanation
      })
    end
  end
end

