class ChefStepsAdmin.Views.QuizImages extends Backbone.View
  el: '#image-list'

  initialize: ->
    @collection.on('add', @addImageToList, @)

  render: =>
    @collection.each (image) =>
      @addImageToList(image)
    @

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.QuizImage(model: image)
    @$el.append(view.render().$el)

