@app.directive 'cscomments', ["$compile", ($compile) ->
  restrict: 'E'
  scope: { 
    commentsId: '@'
    seoBot: '@'
  }
  controller: [ "$scope", "$http", ($scope, $http) ->
    $scope.renderSeoComments = ->
      console.log 'rendering SEO COMMENTS'
      $scope.seoComments = []
      $http.get('http://production-bloom.herokuapp.com/discussion/' + $scope.commentsId + '/comments?apiKey=xchefsteps').then (response) ->
        comments = response.data
        angular.forEach comments, (comment) ->
          $scope.seoComments.push(comment.content)
  ]
  link: (scope, element, attrs) ->
    console.log "THIS IS THE SEO BOT: ", scope.seoBot
    if scope.seoBot == 'true'
      scope.renderSeoComments()
      element.replaceWith($compile("<div>{{seoComments}}</div>")(scope))
    else
      Bloom.installComments {
        el: element[0]
        id: scope.commentsId
      }
]