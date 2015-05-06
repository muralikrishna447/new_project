@components.filter 'aspect1to1', ->
  (image) ->
    image + '/convert?fit=crop&h=600&w=600&quality=90&cache=true'

@components.filter 'words', ->
  (input, words) ->
    if isNaN(words)
      return input
    if words <= 0
      return ''
    if input
      inputWords = input.split(/\s+/)
      if inputWords.length > words
        input = inputWords.slice(0, words).join(' ') + '…'
    input

@components.filter 'sentences', ->
  (input, sentences) ->
    if isNaN(sentences)
      return input
    if sentences <= 0
      return ''
    if input
      inputSentences = input.replace(/([.?!])\s*(?=[A-Z])/g, "$1|").split('|')
      if inputSentences.length > sentences
        input = inputSentences.slice(0, sentences).join(' ')
    input
