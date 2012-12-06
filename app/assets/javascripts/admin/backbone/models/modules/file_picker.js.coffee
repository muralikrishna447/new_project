ChefStepsAdmin.Models.Modules.FilePicker =
  destroySuccess: ->
    throw new Error("NotImplementedError")

  destroyImage: ->
    filepicker.remove(@buildFPFile(), @destroySuccess)

  buildFPFile: ->
    file = {}
    file.url = @get('url')
    file.filename = @get('filename')
    file

