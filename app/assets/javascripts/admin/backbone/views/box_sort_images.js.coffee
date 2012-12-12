class ChefStepsAdmin.Views.BoxSortImages extends Backbone.View
  el: '#image-list'

  initialize: ->
    @collection.on('add', @addImageToList, @)

  render: =>
    @collection.each (image) =>
      @addImageToList(image)
    @

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.BoxSortImage(model: image)
    @$el.append(view.render().$el)

