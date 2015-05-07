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
      switch scope.component.form.mode
        when 'api'
          source = scope.component.form.metadata.source
          mapper = scope.component.form.metadata.mapper
          if source
            $http.get(source).success((data, status, headers, config) ->
              scope.component.response = data
              scope.component.content = {}
              angular.forEach mapper, (responseKey, componentKey) ->
                scope.component.content[componentKey] = scope.component.response[responseKey]
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
      # console.log 'newValue: ', newValue
      # console.log 'oldValue: ', oldValue
      switch scope.component.mode
        when 'api'
          scope.content = {}
          scope.content.buttonMessage = scope.component.metadata.content.buttonMessage
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          if source
            $http.get(source).success((data, status, headers, config) ->
              scope.response = data
              angular.forEach mapper, (responseKey, componentKey) ->
                scope.content[componentKey] = scope.response[responseKey]
            )
        when 'custom'
          scope.content = scope.component.metadata.content
    ), true

  templateUrl: '/client_views/component_hero.html'
]
