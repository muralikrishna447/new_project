class ChefSteps.Views.OrderSortQuestion extends ChefSteps.Views.Question
  templateName: 'order_sort_question'

  initialize: (options)->
    @images = options.model.attributes.images
    @

  render: =>
    super
    @renderGridImages()
    @setDraggable()
    @

  renderGridImages: =>
    for image in @images
      @addImageToGrid(image)
    @

  # Given an image, builds the template and inserts it into .grid-container.
  addImageToGrid: (image)->
    view = new ChefSteps.Views.OrderSortImage(image: image)
    @dragContainer().append(view.render().$el)

  setDraggable: ->
    @dragContainer().shapeshift({
      dragWhitelist: '.draggable',
      centerGrid: true,
      columns: 4,
      animateSpeed: 350
    })

  dragContainer: ->
    @$('.grid-container')
