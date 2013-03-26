class ChefStepsAdmin.Views.OrderSortSolution extends ChefSteps.Views.TemplatedView
  className: 'solution'
  templateName: 'admin/order_sort_solution'

  initialize: (options) ->
    @solution = options.solution
    @imageCollection = options.imageCollection

  render: =>
    @$el.html(@renderTemplate())
    @updateSolutionField()
    @makeSortable()
    @
 
  makeSortable: =>
    # Make this sortable.
    view = @
    el = @$el
    el.find('ol').sortable(
      update: (e, ui) ->
        # Mark the solution as edited (or 'dirty') when the user drags an item.
        # That way we can show them that they need to save the page.
        el.addClass('dirty')
        view.refreshSolution()
    )

  refreshSolution: =>
    @solution = _.map @$el.find('.solution-list li'), (el) ->
      parseInt($(el).attr('data-image-id'))

    @updateSolutionField()

  updateSolutionField: ->
    @$el.find('.solution-field').attr('value', @solution.join(','))

  solutionsForRendering: ->
    collection = @imageCollection

    _.map @solution, (imageId) ->
      {
        imageId: imageId,
        caption: collection.get(imageId).get('caption')
      }

  extendTemplateJSON: (templateJSON) =>
    templateJSON['solutions'] = @solutionsForRendering()
    templateJSON
