class ChefSteps.Collections.Questions extends Backbone.Collection

  model: ChefSteps.Models.Question

  initialize: (options)->
    @index = 0

  current: ->
    @at(@index)

  next: ->
    @index += 1
    @trigger('next', @current())

