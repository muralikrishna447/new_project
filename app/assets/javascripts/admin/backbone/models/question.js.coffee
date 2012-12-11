class ChefStepsAdmin.Models.Question extends Backbone.Model

  destroy: =>
    @destroyImage(false)
    super

_.defaults(ChefStepsAdmin.Models.Question.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

