class ChefSteps.Views.BoxSortImageSet extends Backbone.View
  initialize: (options)->
    @placedClass = 'image-placed'

    @$dropTargets = @$('.sort-option')
    @$dropTargets.droppable
      activeClass: 'image-active'
      hoverClass: 'image-hover'
      tolerance: 'intersect'
      drop: @handleDrop

    @createDraggable()

  handleDrop: (event, ui)=>
    $(event.target).append(ui.draggable).addClass(@placedClass)
    @$dropTargets.css('z-index': 1)
    @makeNextImageDraggable() if @draggedFromPile

  handleDragStart: (event, ui)=>
    $(ui.helper).parent().css('z-index': 10)
    @$dropTargets.removeClass(@placedClass)
    @$dropTargets.find('img').remove() if @draggedFromPile

  moveImages: ->
    @allImages().css(left: '-=5', top: '-=5')
    @allImages().animate(
      {left: '+=5', top: '+=5'},
      complete: =>
        @allImages().css(left: '', top: '')
    )

  topImage: ->
    $('.image-pile img:first')

  allImages: ->
    $('.image-pile img')

  dragHelper: (event)=>
    image = $(event.currentTarget)
    @draggedFromPile = image.parents().hasClass('image-pile')
    return image.clone() if @draggedFromPile
    image

  makeNextImageDraggable: ->
    @moveImages()
    @createDraggable()

  createDraggable: =>
    @topImage().draggable
      containment: '.hero-unit'
      revert: 'invalid'
      helper: @dragHelper
      opacity: 0.6
      zIndex: 10000
      start: @handleDragStart

