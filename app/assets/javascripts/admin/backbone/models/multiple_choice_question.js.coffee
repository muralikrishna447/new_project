class ChefStepsAdmin.Models.MultipleChoiceQuestion extends ChefStepsAdmin.Models.Question
  defaults:
    'instructions': 'Please select one of the following options.'

  toJSON: (options) =>
    attributes = _.clone(@attributes)
    if image = attributes['image']
      attributes['image'] = _.clone(image)
    attributes

  destroySuccess: =>
    @set('image', {})
    @save()

  getImage: =>
    @get('image')

  snapshot: ->
    @attributeSnapshot = @toJSON()

  revert: ->
    return unless @attributeSnapshot
    @clear(silent: true)
    @set(@attributeSnapshot)
