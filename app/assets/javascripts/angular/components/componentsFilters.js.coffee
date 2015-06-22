@components.filter 'aspect1to1', ->
  (image) ->
    image + '/convert?fit=crop&h=600&w=600&quality=90&cache=true'

@components.filter 'aspect16to9', ->
  (image) ->
    image + '/convert?fit=crop&h=900&w=1600&quality=90&cache=true'

@components.filter 'aspect3to1', ->
  (image) ->
    image + '/convert?fit=crop&h=600&w=1800&quality=90&cache=true'

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

@components.filter 'noShortcodes', ->
  (input) ->
    input.replace(/\[(\w+)\s+([^\]]*)\]/, '')

@components.filter 'charLimit', ->
  (input, maxCharNum) ->
    if !input
      ''
    maxCharNum = parseInt(maxCharNum, 10)

    if !maxCharNum
      input

    if input.length <= maxCharNum
      input

    if input.length > maxCharNum
      input = input.substr(0, maxCharNum)

      # Remove the last word fragment if there is one
      lastspace = input.lastIndexOf(' ')
      if lastspace != -1
        input = input.substr(0, lastspace)

      # Remove last punctuations
      lastchar = input.slice(-1)
      if lastchar in ['.', '?', '!', ',', ':']
        input = input.substr(0, input.length - 1)

      # Add Ellipsis
      input = input + '…'

    input

@components.filter 'toTrusted', ['$sce', ($sce) ->
  (input) ->
    $sce.trustAsHtml(input)
]
