window.markdownConverter = new Showdown.converter()

@helpers.filter "markdown", ->
  (input) ->
    if input && markdownConverter
      result = markdownConverter.makeHtml(input)
      result
    else
      ""
