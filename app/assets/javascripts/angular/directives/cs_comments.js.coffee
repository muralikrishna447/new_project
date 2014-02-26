@app.directive 'csComments', ->
  restrict: 'E'
  scope: {
    getWith: '='
  }
  templateUrl: '/client_views/_cs_comments'
  link: (scope, element, attrs) ->
    console.log scope.getWith