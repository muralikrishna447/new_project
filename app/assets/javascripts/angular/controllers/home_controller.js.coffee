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