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
#             if list.maxitems
#               contentData = contentData.slice(0, list.maxitems)

#             scope.content = contentData
#             return
#           ).error (data, status, headers, config) ->
#             console.log data
#             return

#   templateUrl: '/client_views/component_list.html'
# ]

@components.directive 'list', ['$http', ($http) ->
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
          maxitems = scope.component.metadata.maxitems
          $http.get(source).success((data, status, headers, config) ->
            contentData = data
            if maxitems
              scope.response = contentData.slice(0, maxitems)
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

@components.directive 'listForm', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if scope.component.form.mode == 'api'
        source = scope.component.form.metadata.source
        mapper = scope.component.form.metadata.mapper
        maxitems = scope.component.form.metadata.maxitems
        $http.get(source).success((data, status, headers, config) ->
          contentData = data
          if maxitems
            scope.component.response = contentData.slice(0, maxitems)
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
