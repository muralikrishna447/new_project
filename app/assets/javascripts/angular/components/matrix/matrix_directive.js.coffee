@components.directive 'matrixForm', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypeOptions = [
      {
        name: 'Standard'
        attrs: ['title', 'image', 'buttonMessage', 'url']
      }
      {
        name: 'Circle'
        attrs: ['title', 'image', 'buttonMessage', 'url']
      }
    ]

    scope.getKeys = (object) ->
      console.log 'Object: ', object
      Object.keys(object)

  templateUrl: '/client_views/component_matrix_form.html'
]

@components.directive 'matrix', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, element, attrs) ->
    scope.content = []

    updateItems = (newItems) ->
      numRows = scope.component.metadata.rows
      numCols = scope.component.metadata.columns
      if numRows && numCols
        matrix = []
        i = 0
        while i < numRows
          matrix[i] = []
          j = 0
          while j < numCols
            # Add new item
            if newItems
              index = numCols*i + j
              matrix[i][j] = newItems[index]
            # Add existing item
            else if scope.items && scope.items[i] && scope.items[i][j]
              matrix[i][j] = scope.items[i][j]
            # Add blank item
            else
              matrix[i][j] = null
            j++
          i++
        console.log 'Matrix: ', matrix
        scope.items = matrix

    scope.$watch 'component', ((newValue, oldValue) ->
      # switch scope.component.mode
      #   when'api'
      #     if scope.component.metadata
      #       source = scope.component.metadata.source
      #       mapper = scope.component.metadata.mapper
      #       Mapper.do(source, mapper).then (content) ->
      #         scope.content = content
      #         updateItems(scope.content)
      if scope.component.metadata
        source = scope.component.metadata.source
        mapper = scope.component.metadata.mapper
        if source && mapper
          Mapper.do(source, mapper).then (content) ->
            scope.content = content
            updateItems(scope.content)
        else
          updateItems()
    ), true

  templateUrl: '/client_views/component_matrix.html'
]
