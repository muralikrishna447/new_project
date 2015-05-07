@components.directive 'heroForm', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      # console.log 'newValue: ', newValue
      # console.log 'oldValue: ', oldValue
      if ! scope.component.form.metadata then scope.component.form.metadata = {}
      if scope.component.form.mode == 'api'
        source = scope.component.form.metadata.source
        mapper = scope.component.form.metadata.mapper
        if source
          $http.get(source).success((data, status, headers, config) ->
            scope.component.response = data
            console.log "scope.component.response: ", scope.component.response
            console.log 'mapper: ', mapper
            scope.component.content = {}
            angular.forEach mapper, (responseKey, componentKey) ->
              scope.component.content[componentKey] = scope.component.response[responseKey]
              console.log 'scope.component.content: ', scope.component.content
          )
      ), true

  templateUrl: '/client_views/component_hero_form.html'
]

@components.directive 'hero', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if scope.component.mode == 'api'
        source = scope.component.metadata.source
        mapper = scope.component.metadata.mapper
        if source
          $http.get(source).success((data, status, headers, config) ->
            scope.response = data
            console.log "scope.component.response: ", scope.component.response
            console.log 'mapper: ', mapper
            scope.content = {}
            angular.forEach mapper, (responseKey, componentKey) ->
              scope.content[componentKey] = scope.response[responseKey]
              console.log 'scope.content: ', scope.content
          )
      ), true

  templateUrl: '/client_views/component_hero.html'
]
