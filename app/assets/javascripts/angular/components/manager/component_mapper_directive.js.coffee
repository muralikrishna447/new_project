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
      connections = []
      componentKeys.map (componentKey) ->
        # connections[componentKey] = componentKey
        connection =
          componentKey: componentKey
          sourceKey: componentKey
          value: ''
        connections.push connection
    # scope.component.form.metadata.connections = connections
    scope.connections = connections

    scope.$watch 'source', (newValue, oldValue) ->
      if newValue
        $http.get(newValue).success (data, status, headers, config) ->
          scope.response = data
          if data.length
            # Array of items
            scope.responseKeys = Object.keys(data[0])

            scope.mapped = data.map (item) ->
              # console.log 'Here is an Item: ', item
              mappedItem = {}
              angular.forEach connections, (connection) ->
                mappedItem[connection.componentKey] = item[connection.sourceKey]
              return { content: mappedItem }
          else
            # Single items
            scope.responseKeys = Object.keys(data)
            mappedItem = {}
            item = data
            angular.forEach connections, (connection) ->
              mappedItem[connection.componentKey] = item[connection.sourceKey]
            scope.mapped = mappedItem
            return { content: mappedItem }

    scope.changeValue = (connection) ->
      if connection.value && connection.value.length > 0
        connection.sourceKey = null

    scope.changeSourceKey = (connection) ->
      if connection.sourceKey && connection.sourceKey.length > 0
        connection.value = ''

  templateUrl: '/client_views/component_mapper.html'
]
