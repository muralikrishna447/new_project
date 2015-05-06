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

@componentsManager.directive 'list', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      if newValue
        if scope.component.mode == 'api'
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          maxItems = scope.component.metadata.maxItems
          $http.get(source).success((data, status, headers, config) ->
            contentData = data
            if maxItems
              scope.response = contentData.slice(0, maxItems)
            else
              scope.response = contentData
            scope.content = scope.response.map (item) ->
              transformedItem = {}
              angular.forEach mapper, (responseKey, componentKey) ->
                transformedItem[componentKey] = item[responseKey]
              return transformedItem
          )
    ), true

  templateUrl: '/client_views/component_list.html'
]

@componentsManager.directive 'listForm', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      if scope.component.form.mode == 'api'
        source = scope.component.form.metadata.source
        mapper = scope.component.form.metadata.mapper
        maxItems = scope.component.form.metadata.maxItems
        $http.get(source).success((data, status, headers, config) ->
          contentData = data
          if maxItems
            scope.component.response = contentData.slice(0, maxItems)
          else
            scope.component.response = contentData
          scope.component.content = scope.component.response.map (item) ->
            transformedItem = {}
            angular.forEach mapper, (responseKey, componentKey) ->
              transformedItem[componentKey] = item[responseKey]
            return transformedItem
        )
      ), true

  templateUrl: '/client_views/component_list_form.html'
]
