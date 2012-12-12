class ChefSteps.Views.BoxSortImageSet extends Backbone.View
  initialize: (options)->
    @$dropTargets = @$('.sort-option')
    @$dropTargets.droppable
      activeClass: 'image-active'
      hoverClass: 'image-hover'
      tolerance: 'intersect'
      drop: @handleDrop

    @createDraggable()

  handleDrop: (event, ui)=>
    fromPile = $(ui.draggable).parents().hasClass('image-pile')
    $(event.target).append(ui.draggable)
    if fromPile
      @moveImages()
      @createDraggable()
    $(event.target).addClass('image-placed')
    @$dropTargets.css('z-index': 1)

  handleDragStart: (event, ui)=>
    $(ui.helper).parent().css('z-index': 10)
    @$dropTargets.removeClass('image-placed')
    @$dropTargets.find('img').remove() if @draggedFromPile(ui.helper)

  moveImages: ->
    @allImages().css(left: '-=5', top: '-=5')
    @allImages().animate(
      {left: '+=5', top: '+=5'},
      complete: =>
        @allImages().css(left: '', top: '')
    )

  draggedFromPile: (draggable)->
    $(draggable).parents().hasClass('image-pile')

  topImage: ->
    $('.image-pile img:first')

  allImages: ->
    $('.image-pile img')

  dragHelper: (event)=>
    image = $(event.currentTarget)
    if $(image).parents().hasClass('image-pile')
      $(image).clone()
    else
      $(image)

  createDraggable: =>
    @topImage().draggable
      containment: '.hero-unit'
      revert: 'invalid'
      helper: @dragHelper
      opacity: 0.6
      zIndex: 10000
      start: @handleDragStart

