@app.directive 'csIndexItem', [ ->
  restrict: 'E'
  scope: {
    title: '='
    url: '='
    image: '='
    likesCount: '='
  }

  link: (scope, element, attrs) ->
    # console.log 'cs index item loaded'

  templateUrl: '/client_views/cs_index_item'

]