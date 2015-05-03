@app.filter 'aspect1to1', ->
  (image) ->
    image + '/convert?fit=crop&h=600&w=600&quality=90&cache=true'

@app.filter 'words', ->
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

@app.filter 'sentences', ->
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

@app.service 'ApiTransformer', [->
  @transform = (response) ->
    result = {}
    result.title = response.title if response.title
    result.image = response.image if response.image
    result.targetURL = response.url if response.url
    return result

  @getKeys = (response) ->
    Object.keys(response)

  return this
]

@app.controller 'HomeManagerController', ['$scope', ($scope) ->
  @content = []
  @showAddMenu = false

  @addToggle = ->
    @showAddMenu = ! @showAddMenu

  @add = (containerType, defaults = {}) ->
    addData = angular.extend {containerType: containerType, formState: 'new'}, defaults
    @content.push addData
    @showAddMenu = false

  return this
]

@app.controller 'HomeController', ['$scope', ($scope) ->

  @components = [
    {
      componentType: 'list'
      mode: 'api'
      metadata: {
        source: 'http://localhost:3000/api/v0/activities'
        mapper: {
          title: 'title'
          image: 'image'
          targetURL: 'url'
          description: 'description'
        }
        maxItems: 3
      }
    }
  ]

  # @content = [
  #   {
  #     containerType: 'hero'
  #     source: 'http://localhost:3000/api/v0/activities/2434'
  #   }
  #   {
  #     containerType: 'standard'
  #     source: 'http://localhost:3000/api/v0/activities'
  #     maxItems: 3
  #     itemType: 'standard'
  #   }
  # ]

  @example = [
    # {
    #   containerType: 'hero'
    #   mode: 'api'
    #   source: 'http://localhost:3000/api/v0/activities/2434'
    #   buttonMessage: 'Hello'
    #   targetURL: 'hey'
    # }
    # {
    #   containerType: 'matrix'
    #   rows: '2'
    #   columns: '3'
    #   source: 'http://localhost:3000/api/v0/activities'
    #   mode: 'api'
    #   connections: {
    #     title: 'title'
    #     image: 'image'
    #     buttonMessage: 'title'
    #     targetURL: 'url'
    #   }
    #   # items: []
    # }
  ]

  return this

]
