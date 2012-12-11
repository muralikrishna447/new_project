class ChefSteps.Collections.Questions extends Backbone.Collection
  model: (attrs, options) ->
    new ChefSteps.Models.Question(attrs, options)

  initialize: (options)->
    @index = 0

  current: ->
    @at(@index)

  next: ->
    @index += 1
    @trigger('next', @current())
