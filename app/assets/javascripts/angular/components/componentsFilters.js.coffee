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
    input.replace(/\[(\w+)\s+([^\]]*)\]/g, '')

# Used to turn anchor tags to text.
# Useful for turning things like <a href='http://www.somelonglink.com' target='_blank'>hello</a>
# to just 'hello' so it doesn't count against a truncation character count
@components.filter 'linkToText', ->
  (input) ->
    anchorTagRegex = /<a+(>|.*?[^?]>).*<\/a+(>|.*?[^?]>)/g
    input = input.replace(anchorTagRegex, (match) ->
      match.replace(/<[^>]+>/gm, '')
    )
    input

# This charLimit filter will:
# 1. Remove the last unclosed html fragment
# 2. Remove any last word fragments
# 3. Remove any last punctuations
# 4. Add an ellipsis
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
      # console.log 'Initial truncation: ', input

      # Remove last unclosed html fragment
      # Find the last potential opening tag
      lastOpeningTagIndex = input.lastIndexOf('<')

      if lastOpeningTagIndex > 0
        lastFragment = input.substr(lastOpeningTagIndex, input.length)
        # Do not process if the fragment is part of a closing tag from a previous tag
        unless lastFragment[1] == '/'
          closingTagRegex = /<\/[a-zA-Z]+(>|.*?[^?]>)/
          # Remove the frament if it does not have a closing tag
          unless lastFragment.match(closingTagRegex)
            input = input.substr(0, lastOpeningTagIndex)

      # Remove the last word fragment if there is one
      lastspace = input.lastIndexOf(' ')
      if lastspace != -1
        input = input.substr(0, lastspace)
      # console.log 'After last word fragment: ', input

      # Remove last punctuations
      lastchar = input.slice(-1)
      if lastchar in ['.', '?', '!', ',', ':']
        input = input.substr(0, input.length - 1)
      # console.log 'After last punctuations: ', input

      # Add Ellipsis
      input = input + '…'

    input

@components.filter 'toTrusted', ['$sce', ($sce) ->
  (input) ->
    $sce.trustAsHtml(input)
]
