@app.directive 'cscomments', ["$compile", ($compile) ->
  restrict: 'E'
  scope: {
    commentsType: '@' 
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
    console.log 'THIS IS THE COMMENTS ID: ', scope.commentsId
    console.log "THIS IS THE SEO BOT: ", scope.seoBot
    scope.$watch 'commentsId', (newValue, oldValue) ->
      console.log 'NEW VALUE: ', newValue
      if newValue
        if scope.seoBot == 'true'
          scope.renderSeoComments()
          element.replaceWith($compile("<div>{{seoComments}}</div>")(scope))
        else
          identifier = scope.commentsType + '_' + scope.commentsId
          Bloom.installComments {
            el: element[0]
            id: identifier
          }
]