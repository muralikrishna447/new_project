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

  answerData: ->
    {
      type: 'order_sort',
      answers: @getImageOrder()
    }

  # Returns a list of image IDs in the currently arranged order.
  getImageOrder: ->
    ids = []
    @dragContainer().children().each (index, item) ->
      ids.push(id) if id = $(item).attr('data-image-id')

    ids

  # Given an image, builds the template and inserts it into .grid-container.
  addImageToGrid: (image)->
    view = new ChefSteps.Views.OrderSortImage(image: image)
    @dragContainer().append(view.render().$el)

  setDraggable: ->
    # Bind `this` to view so the callback function below can work correctly.
    view = @

    # Since the shapeshift() setup requires this view to be inserted into the DOM,
    # we have to set up a function to check for this view's insertion.
    #
    # The most cross-browser way I could find to do this is to check for a parent
    # <body> element every 100ms, and only call the shapeshift() method once the
    # <body> element appears as a parent of $el.
    checkRender = ->
      if view.$el.closest('body').length > 0
        view.setupShapeshift()
      else
        setTimeout(checkRender, 500)

    checkRender()

  setupShapeshift: ->
    view = @
    container = @dragContainer()

    container.shapeshift({
      dragWhitelist: '.draggable',
      centerGrid: true,
      columns: @gridColumns(),
      animateSpeed: 350
    })

    # This callback will fire every time a square is dropped in place.
    #
    # It takes care of updating the step #, and other UI updates on drop.
    container.on 'ss-event-dropped', (e, selected) ->
      stepMarkerFound = false
      items = container.children()

      items.each (index) ->
        item = $(this)

        if item.hasClass('step-marker')
          item.find('.large-num').text(index + 1)

          # Mark the fixed square as complete/incomplete.
          if index == items.length - 1
            item.addClass('complete')
            view.showNext()
          else
            item.removeClass('complete')
            view.hideNext()

          stepMarkerFound = true
        else
          $numIndicator = item.find('div.num')

          if !stepMarkerFound
            $numIndicator.text(index + 1).addClass('show')
          else
            $numIndicator.text('').removeClass('show')
    @

  gridColumns: ->
    if @onMobileDevice() then 3 else 4

  onMobileDevice: ->
    $('body').hasClass('mobile-device')

  dragContainer: ->
    @$('.grid-container')
