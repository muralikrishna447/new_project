class ChefStepsAdmin.Views.OrderSortImages extends Backbone.View
  el: '#image-list'

  initialize: ->
    @collection.on('add', @addImageToList, @)

  render: =>
    @collection.each (image) =>
      @addImageToList(image)
    @

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.OrderSortImage(model: image)

    # $el wraps the template in a <div>, so we want the childNodes.
    @$el.append(view.render().$el.childNodes)
