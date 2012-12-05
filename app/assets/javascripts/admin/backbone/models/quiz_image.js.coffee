class ChefStepsAdmin.Models.QuizImage extends Backbone.Model

  destroySuccess: =>
    @destroy()

  destroyImage: =>
    filepicker.remove(@buildFPFile(), @destroySuccess)

  buildFPFile: =>
    file = {}
    file.url = @get('url')
    file.filename = @get('filename')
    file

