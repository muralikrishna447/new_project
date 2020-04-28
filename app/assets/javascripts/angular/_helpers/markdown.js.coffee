window.markdownConverter = new showdown.Converter()

@helpers.filter "markdown", ->
  (input) ->
    if input && markdownConverter
      result = markdownConverter.makeHtml(input)
      result
    else
      ""
