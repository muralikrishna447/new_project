class ChefStepsAdmin.Models.QuizImage extends Backbone.Model

  destroySuccess: =>
    @destroy()

  getImage: => { filename: @get('filename'), url: @get('url') }

_.defaults(ChefStepsAdmin.Models.QuizImage.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

