@componentsManager.directive 'componentMapper', ['$http', ($http) ->
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
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      console.log 'component: ', scope.component
      if newValue && typeof newValue != 'undefined'
        scope.component.form.metadata.mapper = newValue
      else
        scope.component.form.metadata.mapper = {}

  templateUrl: '/client_views/component_mapper.html'
]
