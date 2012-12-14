class ChefSteps.Collections.BoxSortAnswers extends Backbone.Collection
  model: Backbone.Model

  addAnswer: (imageId, optionUid) ->
    if existing = @get(imageId)
      existing.set(optionUid: optionUid)
    else
      @add(id: imageId, optionUid: optionUid)
