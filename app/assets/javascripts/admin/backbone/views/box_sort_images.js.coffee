class ChefStepsAdmin.Views.BoxSortImages extends Backbone.View
  el: '#image-list'

  initialize: ->
    @collection.on('add', @addImageToList, @)

  render: =>
    @collection.each (image) =>
      @addImageToList(image)
    @makeSortable()
    @

  makeSortable: =>
    @$el.sortable(
      cursor: 'move',
      containment: 'parent',
      items: ".image:not('.image-placeholder')",
      update: @updateOrder
    ).disableSelection()

  updateOrder: =>
    console.log 'update order'
    # @collection.updateOrder(@getQuestionOrder())

  # getQuestionOrder: =>
  #   _.map(@$('.question'), (questionItem) ->
  #     $(questionItem).attr('id').split('-')[1]
  #   )

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.BoxSortImage(model: image)
    @$el.append(view.render().$el)

