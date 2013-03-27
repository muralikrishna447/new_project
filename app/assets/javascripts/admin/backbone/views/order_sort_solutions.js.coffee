class ChefStepsAdmin.Views.OrderSortSolutions extends Backbone.View
  el: '#solutions-list'

  initialize: (options) ->
    @imageCollection = options.imageCollection
    @solutions = options.solutions

    @setupAddNew()

  setupAddNew: ->
    view = @
    $('#add-solution').click (event) ->
      view.addBlankSolution()
      event.preventDefault()

  render: ->
    _.each @solutions, (solution) =>
      @addSolutionToList(solution.order_sort_image_ids)
    @

  

  addBlankSolution: ->
    @addSolutionToList(@imageCollectionIds())
    @

  imageCollectionIds: ->
    @imageCollection.map (image) =>
      image.get('id')

  addSolutionToList: (solution) ->
    view = new ChefStepsAdmin.Views.OrderSortSolution(
      solution: solution,
      imageCollection: @imageCollection
    )

    $solution = view.render().$el
    @$el.append($solution)
