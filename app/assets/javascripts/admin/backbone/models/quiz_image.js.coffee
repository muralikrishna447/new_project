class ChefStepsAdmin.Models.QuizImage extends Backbone.Model

  destroySuccess: =>
    @destroy()

_.defaults(ChefStepsAdmin.Models.QuizImage.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

