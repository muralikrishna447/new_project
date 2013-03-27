class ChefStepsAdmin.Views.OrderSortSolution extends ChefSteps.Views.TemplatedView
  className: 'solution'
  templateName: 'admin/order_sort_solution'

  initialize: (options) ->
    @solution = options.solution
    @imageCollection = options.imageCollection

    @setCaptionHandlerOnImages()

    @imageCollection.on('add', @handleImageAdded, @)

  render: =>
    @$el.html(@renderTemplate())
    @updateSolutionField()
    @makeSortable()
    @

  handleImageAdded: (image) ->
    image.on('change:id', @addImageToSolution, @)

  addImageToSolution: (image) ->
    image.off('change:id', @addImageToSolution, @)
    @solution.push(parseInt(image.id))
    @setCaptionHandler(image)
    @render()
    @markDirty()

  handleImageRemoved: (image) ->


  setCaptionHandlerOnImages: ->
    view = @
    @imageCollection.each (image) ->
      view.setCaptionHandler(image)
    @

  setCaptionHandler: (image) ->
    image.on('change:caption', @refreshForImage, @)

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
