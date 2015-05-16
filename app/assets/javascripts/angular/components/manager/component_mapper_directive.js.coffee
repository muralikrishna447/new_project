@componentsManager.directive 'componentMapper', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    componentKeys: '='
    component: '='
    connections: '='
    source: '='
  }

  link: (scope, element, attrs) ->
    scope.responseKeys = {}

    componentKeys = scope.componentKeys
    console.log 'componentKeys: ', componentKeys
    connections = scope.connections
    unless connections
      connections = {}
      componentKeys.map (componentKey) ->
        connections[componentKey] = componentKey
    scope.component.form.metadata.connections = connections
    scope.connections = connections

    scope.$watch 'source', (newValue, oldValue) ->
      if newValue
        $http.get(newValue).success (data, status, headers, config) ->
          scope.response = data
          if data.length > 1
            scope.responseKeys = Object.keys(data[0])
          else
            scope.responseKeys = Object.keys(data)

          scope.mapped = data.map (item) ->
            # console.log 'Here is an Item: ', item
            mappedItem = {}
            angular.forEach connections, (sourceKey, contentKey) ->
              mappedItem[contentKey] = item[sourceKey]
            return mappedItem

    # scope.$watch 'connections', (newValue, oldValue) ->
    #   console.log 'newValue: ', newValue
    #   console.log 'oldValue: ', oldValue
    #   console.log 'component: ', scope.component
    #   if newValue && typeof newValue != 'undefined'
    #     scope.component.form.metadata.mapper = newValue
    #   else
    #     scope.component.form.metadata.mapper = {}

  templateUrl: '/client_views/component_mapper.html'
]


# @componentsManager.directive 'componentMapper', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     response: '='
#     componentKeys: '='
#     component: '='
#     connections: '='
#   }
#
#   link: (scope, element, attrs) ->
#     scope.responseKeys = {}
#
#     scope.$watch 'response', (newValue, oldValue) ->
#       # console.log 'RESPONSE: ', newValue
#       # console.log 'RESPONSE Type: ', typeof newValue
#       # console.log 'RESPONSE Length: ', newValue.length
#       if newValue
#         if newValue.length && newValue.length > 1
#           scope.responseKeys = Object.keys(newValue[0])
#         else
#           scope.responseKeys = Object.keys(newValue)
#
#     scope.$watch 'connections', (newValue, oldValue) ->
#       console.log 'newValue: ', newValue
#       console.log 'oldValue: ', oldValue
#       console.log 'component: ', scope.component
#       if newValue && typeof newValue != 'undefined'
#         scope.component.form.metadata.mapper = newValue
#       else
#         scope.component.form.metadata.mapper = {}
#
#   templateUrl: '/client_views/component_mapper.html'
# ]
