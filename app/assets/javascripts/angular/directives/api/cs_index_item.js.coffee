@app.directive 'csIndexItem', [ ->
  restrict: 'E'
  scope: {
    csTitle: '='
    url: '='
    image: '='
    likesCount: '='
    difficulty: '='
  }

  link: (scope, element, attrs) ->
    # console.log 'cs index item loaded'

  templateUrl: '/client_views/cs_index_item'

]