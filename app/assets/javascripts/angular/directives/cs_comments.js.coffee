@app.directive 'cscomments', ["$compile", ($compile) ->
  restrict: 'E'
  scope: {
    commentsType: '@' 
    commentsId: '@'
    seoBot: '@'
  }
  controller: [ "$scope", "$http", ($scope, $http) ->
    $scope.renderSeoComments = ->
      $scope.seoComments = ['hello']
      identifier = $scope.commentsType + '_' + $scope.commentsId
      $http.get('http://production-bloom.herokuapp.com/discussion/' + identifier + '/comments?apiKey=xchefsteps').then (response) ->
        comments = response.data
        angular.forEach comments, (comment) ->
          $scope.seoComments.push(comment.content)
  ]
  link: (scope, element, attrs) ->
    scope.$watch 'commentsId', (newValue, oldValue) ->
      if newValue
        if scope.seoBot == 'true'
          scope.renderSeoComments()
        else
          identifier = scope.commentsType + '_' + scope.commentsId
          Bloom.installComments {
            el: element[0]
            id: identifier
            on:
              login: ->
                $rootScope.$apply ->
                  $rootScope.$emit 'openLoginModal'
          }
  template: "<div>{{seoComments}}</div>"
]

@app.directive 'csnotifs', ["$compile", ($compile) ->
  restrict: 'E'
  scope: {}
  link: (scope, element, attrs) ->
    Bloom.installNotifs {
      el: element[0]
    }
]

