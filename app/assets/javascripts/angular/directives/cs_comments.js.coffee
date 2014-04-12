@app.directive 'cscomments', [ ->
  restrict: 'E'
  scope: { commentsId: '@' }
  link: (scope, element, attrs) ->
    console.log element[0]
    console.log 'commentsId is', scope.commentsId
    console.log 'This is the comments directive'
    Bloom.installComments {
      el: element[0]
      id: scope.commentsId
    }
]