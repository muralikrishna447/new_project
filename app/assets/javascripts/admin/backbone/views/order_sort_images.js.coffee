class ChefStepsAdmin.Views.OrderSortImages extends Backbone.View
  el: '#image-list'

  initialize: ->
    @collection.on('add', @addImageToList, @)

  render: =>
    @collection.each (image) =>
      console.log(image)
      @addImageToList(image)
    @

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.OrderSortImage(model: image)

    @$el.append(view.render().$el)
