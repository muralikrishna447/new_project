window.markdownConverter = Markdown.getSanitizingConverter()

angular.module('ChefStepsApp').filter "markdown", ->
  (input) ->
    if input && markdownConverter
      result = markdownConverter.makeHtml(input)
      result
    else
      ""