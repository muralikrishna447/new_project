@app.filter 'aspect1to1', ->
  (image) ->
    image + '/convert?fit=crop&h=600&w=600&quality=90&cache=true' 

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
        }
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