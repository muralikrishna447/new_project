class ImagePresenter < Presenter
  def attributes
    { id: @model.id,
      file_name: @model.file_name,
      caption: @model.caption
    }
  end
end

