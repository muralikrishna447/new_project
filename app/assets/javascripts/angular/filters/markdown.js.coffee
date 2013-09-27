window.markdownConverter = new Showdown.converter()

angular.module('ChefStepsApp').filter "markdown", ->
  (input) ->
    if input && markdownConverter
      result = markdownConverter.makeHtml(input)
      result
    else
      ""