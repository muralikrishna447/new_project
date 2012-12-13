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
    @collection.updateOrder(@getQuestionOrder())

  getQuestionOrder: =>
    _.map(@$('.image:not(.image-placeholder)'), (image) ->
      _.last($(image).attr('id').split('-'))
    )

  addImageToList: (image) =>
    view = new ChefStepsAdmin.Views.BoxSortImage(model: image)
    @$el.append(view.render().$el)

