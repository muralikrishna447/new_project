@components.directive 'matrixForm', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if scope.component.form.mode == 'api'
        if scope.component.form.metadata
          source = scope.component.form.metadata.source
          mapper = scope.component.form.metadata.mapper
          maxitems = scope.component.form.metadata.maxitems
          if source
            $http.get(source).success (data, status, headers, config) ->
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
        else
          scope.component.form.metadata = {}
      ), true

  templateUrl: '/client_views/component_matrix_form.html'
]

@components.directive 'matrix', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, element, attrs) ->

    updateItems = (newItems) ->
      if scope.component.metadata.rows && scope.component.metadata.columns
        # numItems = scope.content.rows * scope.content.columns
        matrix = []
        i = 0
        while i < scope.component.metadata.rows
          matrix[i] = []
          j = 0
          while j < scope.component.metadata.columns
            # console.log 'items: ', scope.content.items
            if newItems
              console.log 'adding new items: ', newItems
              index = scope.component.metadata.columns*i + j
              # console.log 'new items index: ', index
              matrix[i][j] = newItems[index]
            else if scope.items && scope.items[i] && scope.items[i][j]
              matrix[i][j] = scope.items[i][j]
            else
              matrix[i][j] = {}
            j++
          i++
        console.log 'matrix: ', matrix
        scope.items = matrix
        console.log 'items: ', scope.items

    scope.$watch 'component', ((newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if scope.component.mode == 'api'
        if scope.component.metadata
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          maxitems = scope.component.metadata.maxitems
          if source
            $http.get(source).success (data, status, headers, config) ->
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
              updateItems(scope.content)
      ), true

  templateUrl: '/client_views/component_matrix.html'
]

# @components.directive 'matrix', ['$http', ($http) ->
#   restrict: 'A'
#   scope: {
#     content: '='
#   }
#   controller: ['$scope', ($scope) ->
#
#   ]
#   link: (scope, $element, $attrs) ->
#
#     transform = (item, connections) ->
#       transformed = {}
#       angular.forEach connections, (componentKey, responsekey) ->
#         transformed[componentKey] = item[responsekey]
#       return transformed
#
#     updateItems = (newItems) ->
#       # console.log 'NEW: ', newItems
#       if scope.content.rows && scope.content.columns
#         # numItems = scope.content.rows * scope.content.columns
#         matrix = []
#         i = 0
#         while i < scope.content.rows
#           matrix[i] = []
#           j = 0
#           while j < scope.content.columns
#             # console.log 'items: ', scope.content.items
#             if newItems
#               index = scope.content.columns*i + j
#               # console.log 'new items index: ', index
#               matrix[i][j] = newItems[index]
#             else if scope.content.items && scope.content.items[i] && scope.content.items[i][j]
#               matrix[i][j] = scope.content.items[i][j]
#             else
#               matrix[i][j] = {}
#             j++
#           i++
#         scope.content.items = matrix
#
#     scope.$watch 'content.rows', (newValue, oldValue) ->
#       # console.log 'content: ', newValue
#       updateItems()
#
#     scope.$watch 'content.columns', (newValue, oldValue) ->
#       # console.log 'content: ', newValue
#       updateItems()
#
#     scope.$watch 'content.source', (newValue, oldValue) ->
#       # console.log 'source: ', newValue
#       if newValue
#         $http.get(newValue).success((data, status, headers, config) ->
#           scope.content.response = data
#           # console.log 'connections: ', scope.content.connections
#           # angular.forEach scope.content.connections, (connection) ->
#           #   console.log 'CONNECTION: ', connection
#           updateItems(data)
#           return
#         ).error (data, status, headers, config) ->
#           console.log data
#           return
#
#     scope.$watch 'content.connections', ((newValues, oldValues) ->
#       console.log 'Connection updated to: ', newValues
#       # console.log 'Response: ', scope.content.response
#       # transformed = {}
#       # angular.forEach newValues, (componentKey, responsekey) ->
#       #   transformed[componentKey] = scope.content.response[responsekey]
#       # console.log 'transformed: ', transformed
#       if newValues
#         transformed = []
#         angular.forEach scope.content.response, (item) ->
#           transformedItem = {}
#           angular.forEach newValues, (responseKey, componentKey) ->
#             transformedItem[componentKey] = item[responseKey]
#           transformed.push transformedItem
#           console.log 'Transformed Item: ', transformedItem
#         updateItems(transformed)
#     ), true
#
#     # Initializes the matrix and watches for changes
#     scope.$watch 'content.response', (newValues, oldValues) ->
#       if newValues
#         console.log newValues
#         transformed = []
#         angular.forEach newValues, (item) ->
#           transformedItem = {}
#           angular.forEach scope.content.connections, (responseKey, componentKey) ->
#             transformedItem[componentKey] = item[responseKey]
#           transformed.push transformedItem
#           console.log 'Transformed Item: ', transformedItem
#         updateItems(transformed)
#
#   # templateUrl: '/client_views/container_matrix.html'
#   templateUrl: '/client_views/component_matrix.html'
# ]
