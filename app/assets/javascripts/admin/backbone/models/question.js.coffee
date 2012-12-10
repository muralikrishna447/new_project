class ChefStepsAdmin.Models.Question extends Backbone.Model
  defaults:
    'instructions': 'Please select one of the following options.'

  destroySuccess: =>
    @set('image', {})
    @save()

  toJSON: (options) =>
    attributes = _.clone(@attributes)
    if image = attributes['image']
      attributes['image'] = _.clone(image)
    attributes

  destroy: =>
    @destroyImage(false)
    super

  getImage: =>
    @get('image')

_.defaults(ChefStepsAdmin.Models.Question.prototype, ChefStepsAdmin.Models.Modules.FilePicker)

