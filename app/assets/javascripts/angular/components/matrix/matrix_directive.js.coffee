@components.directive 'matrixForm', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->

  templateUrl: '/client_views/component_matrix_form.html'
]

# @components.directive 'matrixForm', ['$http', 'Mapper', ($http, Mapper) ->
#   restrict: 'A'
#   scope: {
#     component: '='
#   }
#   link: (scope, $element, $attrs) ->
#     scope.component.content = []
#     scope.$watch 'component', ((newValue, oldValue) ->
#       # console.log 'newValue: ', newValue
#       # console.log 'oldValue: ', oldValue
#       if ! scope.component.form.metadata then scope.component.form.metadata = {}
#       switch scope.component.form.mode
#         when 'api'
#           source = scope.component.form.metadata.source
#           mapper = scope.component.form.metadata.mapper
#           maxitems = scope.component.form.metadata.maxitems
#           if source
#             $http.get(source).success (data, status, headers, config) ->
#               contentData = data
#               if maxitems
#                 scope.component.response = contentData.slice(0, maxitems)
#               else
#                 scope.component.response = contentData
#               Mapper.mapArray(mapper, scope.component.content, scope.component.response)
#     ), true
#
#   templateUrl: '/client_views/component_matrix_form.html'
# ]
#
# @components.directive 'matrix', ['$http', 'Mapper', ($http, Mapper) ->
#   restrict: 'A'
#   scope: {
#     component: '='
#   }
#   link: (scope, element, attrs) ->
#     scope.content = []
#     updateItems = (newItems) ->
#       if scope.component.metadata.rows && scope.component.metadata.columns
#         # numItems = scope.content.rows * scope.content.columns
#         matrix = []
#         i = 0
#         while i < scope.component.metadata.rows
#           matrix[i] = []
#           j = 0
#           while j < scope.component.metadata.columns
#             # console.log 'items: ', scope.content.items
#             if newItems
#               console.log 'adding new items: ', newItems
#               index = scope.component.metadata.columns*i + j
#               # console.log 'new items index: ', index
#               matrix[i][j] = newItems[index]
#             else if scope.items && scope.items[i] && scope.items[i][j]
#               matrix[i][j] = scope.items[i][j]
#             else
#               matrix[i][j] = {}
#             j++
#           i++
#         console.log 'matrix: ', matrix
#         scope.items = matrix
#         console.log 'items: ', scope.items
#
#     scope.$watch 'component', ((newValue, oldValue) ->
#       console.log 'newValue: ', newValue
#       console.log 'oldValue: ', oldValue
#       switch scope.component.mode
#         when'api'
#           if scope.component.metadata
#             source = scope.component.metadata.source
#             mapper = scope.component.metadata.mapper
#             maxitems = scope.component.metadata.maxitems
#             if source
#               $http.get(source).success (data, status, headers, config) ->
#                 contentData = data
#                 if maxitems
#                   scope.response = contentData.slice(0, maxitems)
#                 else
#                   scope.response = contentData
#                 Mapper.mapArray(mapper, scope.content, scope.response)
#                 updateItems(scope.content)
#     ), true
#
#   templateUrl: '/client_views/component_matrix.html'
# ]
