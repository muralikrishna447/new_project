class ChefStepsAdmin.Views.OrderSortSolution extends ChefSteps.Views.TemplatedView
  className: 'solution'
  templateName: 'admin/order_sort_solution'

  initialize: (options) ->
    @solution = options.solution
    @imageCollection = options.imageCollection

    @setHandlersOnImages()

    @imageCollection.on('add', @handleImageAdded, @)

  render: =>
    @$el.html(@renderTemplate())
    @updateSolutionField()
    @makeSortable()
    @setupRemoveLink()
    @

  handleImageAdded: (image) ->
    image.on('change:id', @addImageToSolution, @)

  addImageToSolution: (image) ->
    image.off('change:id', @addImageToSolution, @)

    @solution.push(parseInt(image.id))

    @setCaptionHandler(image)
    @setDestroyHandler(image)

    @render()
    @markDirty()

  setupRemoveLink: ->
    view = @
    @$el.find('.remove').click (event) ->
      view.removeSolution()
      event.preventDefault()

  removeSolution: ->
    @undelegateEvents()
    @$el.removeData().unbind()

    @remove()

  setHandlersOnImages: ->
    view = @
    @imageCollection.each (image) ->
      view.setCaptionHandler(image)
      view.setDestroyHandler(image)
    @

  setCaptionHandler: (image) ->
    image.on('change:caption', @refreshForImage, @)

  setDestroyHandler: (image) ->
    image.on('destroy', @handleImageDestroy, @)

  handleImageDestroy: (image) ->
    @solution.remove(image.get('id'))
    @render()
    @markDirty()

  refreshForImage: (image) ->
    @render()
 
  makeSortable: =>
    # Make this sortable.
    view = @
    @$el.find('ol').sortable(
      update: (e, ui) ->
        # Mark the solution as edited (or 'dirty') when the user drags an item.
        # That way we can show them that they need to save the page.
        view.markDirty()
        view.refreshSolution()
    )

  markDirty: ->
    @$el.addClass('dirty')

  refreshSolution: =>
    @solution = _.map @$el.find('.solution-list li'), (el) ->
      parseInt($(el).attr('data-image-id'))

    @updateSolutionField()

  updateSolutionField: ->
    @$el.find('.solution-field').attr('value', @solution.join(','))

  solutionsForRendering: ->
    collection = @imageCollection

    _.map @solution, (imageId) ->
      image = collection.get(imageId)
      caption = if _.isUndefined(image) then 'no caption set' else image.get('caption')

      {
        imageId: imageId,
        caption: caption
      }

  extendTemplateJSON: (templateJSON) =>
    templateJSON['solutions'] = @solutionsForRendering()
    templateJSON
