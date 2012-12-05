class ImagePresenter < Presenter
  def attributes
    {
      id: @model.id,
      filename: @model.filename,
      caption: @model.caption,
      url: @model.url
    }
  end
end

