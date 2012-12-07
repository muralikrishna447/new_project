class ChefSteps.Models.Answer extends Backbone.Model
  urlRoot: ->
    "/questions/#{@get('question_id')}/answers"
