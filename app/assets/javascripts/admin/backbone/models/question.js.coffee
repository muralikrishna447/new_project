class ChefStepsAdmin.Models.Question extends Backbone.Model
  defaults:
    'instructions': 'Please select one of the following options.'

  destroySuccess: () ->
    # TODO: Do anything here?

  getImage: =>
    @get('image')

_.defaults(ChefStepsAdmin.Models.Question.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

