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

@app.directive 'apiConnector', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    response: '='
    componentKeys: '='
    component: '='
    connections: '='
  }

  link: (scope, element, attrs) ->
    # scope.connections = {}
    # $http.get('http://localhost:3000/api/v0/activities/2434').success((data, status, headers, config) ->
    #   scope.responseKeys = Object.keys data

    # )
    # scope.connections = {}
    scope.responseKeys = {}

    scope.$watch 'response', (newValue, oldValue) ->
      # console.log 'RESPONSE: ', newValue
      # console.log 'RESPONSE Type: ', typeof newValue
      # console.log 'RESPONSE Length: ', newValue.length
      if newValue
        if newValue.length && newValue.length > 1
          scope.responseKeys = Object.keys(newValue[0])
        else
          scope.responseKeys = Object.keys(newValue)

    scope.$watch 'connections', (newValue, oldValue) ->
      if newValue
        scope.component.connections = newValue

  templateUrl: '/client_views/api_connector.html'
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
  @content = [
    {
      containerType: 'hero'
      source: 'http://localhost:3000/api/v0/activities/2434'
    }
    {
      containerType: 'standard'
      source: 'http://localhost:3000/api/v0/activities'
      maxItems: 3
      itemType: 'standard'
    }
  ]

  @example = [
    {
      containerType: 'hero'
      mode: 'api'
      source: 'http://localhost:3000/api/v0/activities/2434'
      buttonMessage: 'Hello'
      targetURL: 'hey'
    }
    {
      containerType: 'matrix'
      rows: '2'
      columns: '3'
      source: 'http://localhost:3000/api/v0/activities'
      mode: 'api'
      connections: {
        title: 'title'
        image: 'image'
        buttonMessage: 'title'
        targetURL: 'url'
      }
      # items: []
    }
  ]

  return this

]

@app.directive 'csContainerForm', [ ->
  restrict: 'A'
  scope: {
    formData: '='
    formState: '='
  }
  link: (scope, element, attrs) ->
    # console.log 'formData: ', scope.formData
    scope.container = {}
    scope.container.form = scope.formData

    scope.includePreview = (containerType) ->
      return "/client_views/container_#{containerType}.html"

    scope.includeForm = (containerType) ->
      return "/client_views/container_#{containerType}_form.html"

    scope.toggle = ->
      if scope.formState == 'edit'
        scope.formState = ''
      else if scope.formState == 'new'
        scope.formState = ''
      else
        scope.formState = 'edit'
  templateUrl: '/client_views/cs_container_form.html'
]

@app.directive 'containerHero', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    containerHero: '@'
  }
  controller: ['$scope', ($scope) ->
    $scope.content = {}
  ]
  link: (scope, $element, $attrs) ->
    scope.$watch 'containerHero', (newValue, oldValue) ->
      # console.log 'newValue containerHero: ', newValue
      # console.log 'oldValue containerHero: ', oldValue
      hero = JSON.parse(newValue)
      scope.content.buttonMessage = hero.buttonMessage
      scope.content.targetURL = hero.targetURL

      switch hero.mode
        when 'api'
          if hero.source
            $http.get(hero.source).success((data, status, headers, config) ->
              scope.content.image = data.image
              scope.content.title = data.title
              return
            ).error (data, status, headers, config) ->
              console.log data
              return
        when 'custom'
          scope.content.image = hero.image
          scope.content.title = hero.title

  templateUrl: '/client_views/container_hero.html'
]

@app.directive 'containerList', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    containerList: '@'
  }
  link: (scope, $element, $attrs) ->
    scope.content = {}
    scope.$watch 'containerList', (newValue, oldValue) ->
      list = JSON.parse(newValue)
      console.log 'list: ', list
      switch list.mode
        when 'api'
          $http.get(list.source).success((data, status, headers, config) ->
            contentData = data
            if list.maxItems
              contentData = contentData.slice(0, list.maxItems)

            scope.content = contentData
            return
          ).error (data, status, headers, config) ->
            console.log data
            return

  templateUrl: '/client_views/container_list.html'
]

# @app.directive 'containerMatrix', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     containerMatrix: '@'
#   }
#   controller: ['$scope', ($scope) ->
#     $scope.content = {}

#     $scope.createItem = (content, column, row) ->
#       console.log "Creating Item at [#{column},#{row}]"
#       $scope.content.items.push {}
#   ]
#   link: (scope, $element, $attrs) ->
#     scope.numToArray = (num) ->
#       if num
#         return new Array parseInt(num)

#     scope.$watch 'containerMatrix', (newValue, oldValue) ->
#       console.log 'newValue: ', newValue
#       matrix = scope.$eval newValue
#       scope.content = matrix
#       switch matrix.mode
#         when 'api'
#           $http.get(matrix.source).success((data, status, headers, config) ->
#             contentData = data
#             if matrix.maxItems
#               contentData = contentData.slice(0, matrix.maxItems)

#             scope.content = contentData
#             return
#           ).error (data, status, headers, config) ->
#             console.log data
#             return

#   templateUrl: '/client_views/container_matrix.html'
# ]