class ChefSteps.Views.BoxSortImageSet extends Backbone.View
  initialize: (options)->
    @placedClass = 'image-placed'

    @$dropTargets = @$('.sort-option')
    @$caption = @$('.image-caption')

    @createDraggable()
    @createDroppables()

  handleDrop: (event, ui)=>
    $(event.target).append(ui.draggable)
    @makeNextImageDraggable() if @draggedFromPile

  handleStop: (event, ui)=>
    @$dropTargets.find('img').parent().addClass(@placedClass)
    @$dropTargets.css('z-index': 1)

  handleDragStart: (event, ui)=>
    $(ui.helper).parent().css('z-index': 10)

    removePlaced = =>
      @$dropTargets.removeClass(@placedClass)

    if @draggedFromPile
      image = @$dropTargets.find('img')
      image.fadeOut 'fast', =>
        image.remove()
        removePlaced()
    else
      removePlaced()

  moveImages: ->
    allImages = @$('.image-pile img')
    allImages.css(left: '-=5', top: '-=5')
    allImages.animate(
      {left: '+=5', top: '+=5'},
      complete: -> allImages.css(left: '', top: '')
    )

  dragHelper: (event)=>
    image = $(event.currentTarget)
    @draggedFromPile = image.parents().hasClass('image-pile')
    return image.clone() if @draggedFromPile
    image

  makeNextImageDraggable: ->
    @updateCaption()
    @moveImages()
    @createDraggable()

  nextImage: ->
    @$('.image-pile img:first')

  updateCaption: ->
    @$caption.fadeOut 'fast', =>
      @$caption.text(@nextImage().data('caption')).fadeIn('fast')

  createDraggable: =>
    @nextImage().draggable
      containment: '.hero-unit'
      revert: 'invalid'
      helper: @dragHelper
      opacity: 0.6
      zIndex: 10000
      start: @handleDragStart
      stop: @handleStop

  createDroppables: =>
    @$dropTargets.droppable
      activeClass: 'image-active'
      hoverClass: 'image-hover'
      tolerance: 'intersect'
      drop: @handleDrop
