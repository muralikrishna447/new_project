@app.directive 'matrixItem', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    content: '='
    mode: '='
    formState: '='
  }

  templateUrl: '/client_views/container_matrix_item.html'
]