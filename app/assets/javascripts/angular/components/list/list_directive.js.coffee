# @app.directive 'list', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     containerList: '@'
#   }
#   link: (scope, $element, $attrs) ->
#     scope.content = {}
#     scope.$watch 'list', (newValue, oldValue) ->
#       list = JSON.parse(newValue)
#       console.log 'list: ', list
#       switch list.mode
#         when 'api'
#           $http.get(list.source).success((data, status, headers, config) ->
#             contentData = data
#             if list.maxItems
#               contentData = contentData.slice(0, list.maxItems)

#             scope.content = contentData
#             return
#           ).error (data, status, headers, config) ->
#             console.log data
#             return

#   templateUrl: '/client_views/component_list.html'
# ]

@app.directive 'list', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    if scope.component.mode == 'api'
      source = scope.component.metadata.source
      mapper = scope.component.metadata.mapper
      maxItems = scope.component.metadata.maxItems
      $http.get(source).success((data, status, headers, config) ->
        contentData = data
        if maxItems
          scope.component.metadata.response = contentData.slice(0, maxItems)
        scope.component.metadata.content = scope.component.metadata.response.map (item) ->
          transformedItem = {}
          angular.forEach mapper, (responseKey, componentKey) ->
            transformedItem[componentKey] = item[responseKey]
          return transformedItem
      )

  templateUrl: '/client_views/component_list.html'
]

@app.directive 'listForm', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      if scope.component.mode == 'api'
        source = scope.component.metadata.source
        mapper = scope.component.metadata.mapper
        maxItems = scope.component.metadata.maxItems
        $http.get(source).success((data, status, headers, config) ->
          contentData = data
          if maxItems
            scope.component.metadata.response = contentData.slice(0, maxItems)
          scope.component.metadata.content = scope.component.metadata.response.map (item) ->
            transformedItem = {}
            angular.forEach mapper, (responseKey, componentKey) ->
              transformedItem[componentKey] = item[responseKey]
            return transformedItem
        )
      ), true

  templateUrl: '/client_views/component_list_form.html'
]