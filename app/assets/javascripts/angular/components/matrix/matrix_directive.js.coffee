# Service to put a list of items into a matrix given a set number of rows and columns
# May or may not need it
@components.service 'Matrix', [ ->

  @do = (numRows, numCols, newItems) ->
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
      return matrix

  return this
]

@components.directive 'matrixForm', ['$http', 'Mapper', 'Matrix', ($http, Mapper, Matrix) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypeOptions = [
      {
        name: 'Square A'
        className: 'square.square-a'
        attrs: ['title', 'image', 'buttonMessage', 'url']
        templateUrl: 'component_matrix_item_square_a.html'
        formTemplateUrl: 'component_matrix_item_square_a_form.html'
      }
      {
        name: 'Circle'
        attrs: ['title', 'image', 'buttonMessage', 'url']
      }
    ]

    scope.$watch 'component.form.mode', (newValue, oldValue) ->
      apiMode = newValue
      if apiMode
        switch apiMode
          when 'api'
            console.log 'API MODE'
          when 'custom'
            console.log 'scope.component', scope.component
            Mapper.do(scope.component.form.metadata.source, scope.component.form.metadata.mapper).then (content) ->
              scope.component.form.metadata.items = content
            # Mapper.do(scope.component.form.metadata.source, scope.component.form.metadata.mapper).then (content) ->
            #   scope.component.form.metadata.items = Matrix.do(scope.component.form.metadata.rows, scope.component.form.metadata.columns, content)

    scope.getTemplate = (templateUrl) ->
      return '/client_views/' + templateUrl

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
      if scope.component.metadata
        switch scope.component.mode
          when 'api'
            source = scope.component.metadata.source
            mapper = scope.component.metadata.mapper
            if source && mapper
              Mapper.do(source, mapper).then (content) ->
                scope.content = content
                updateItems(scope.content)
            else
              updateItems()
          when 'custom'
            scope.items = updateItems(scope.component.metadata.items)
    ), true

    scope.getTemplate = (templateUrl) ->
      return '/client_views/' + templateUrl

  templateUrl: '/client_views/component_matrix.html'
]
