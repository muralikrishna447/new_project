@app.directive 'hero', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    hero: '@'
  }
  controller: ['$scope', ($scope) ->
    $scope.content = {}
  ]
  link: (scope, $element, $attrs) ->
    scope.$watch 'hero', (newValue, oldValue) ->
      # console.log 'newValue hero: ', newValue
      # console.log 'oldValue hero: ', oldValue
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

  templateUrl: '/client_views/component_hero.html'
]