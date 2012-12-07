ChefStepsAdmin.Models.Modules.FilePicker =
  destroySuccess: ->
    throw new Error("NotImplementedError")

  destroyImage: (includeCallback = true) ->
    if @hasImage()
      if includeCallback
        filepicker.remove(@buildFPFile(), @destroySuccess)
      else
        filepicker.remove(@buildFPFile())

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

