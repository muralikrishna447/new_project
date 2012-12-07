ChefStepsAdmin.Models.Modules.FilePicker =
  destroySuccess: ->
    throw new Error("NotImplementedError")

  destroyImage: ->
    if @hasImage()
      filepicker.remove(@buildFPFile(), @destroySuccess)

  getImage: ->
    throw new Error("NotImplementedError")

  buildFPFile: ->
    file = {}
    image = @getImage()
    file.url = image.url
    file.filename = image.filename
    file

  hasImage: ->
    image = @getImage()
    image && image.url

