@app.directive 'cscomments', [ ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    # console.log element[0]
    # console.log attrs.commentsId
    # console.log 'This is the comments directive'
    # Bloom.installComments {
    #   el: element[0]
    #   id: attrs.commentsId
    # }
]