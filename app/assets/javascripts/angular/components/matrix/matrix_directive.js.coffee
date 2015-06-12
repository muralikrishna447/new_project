# Service to put a list of items into a matrix given a set number of rows and columns

@components.directive 'matrix', [ ->
  restrict: 'A'
  scope: {
    component: '='
  }

  templateUrl: '/client_views/component_matrix.html'
]
