@app.directive 'csCommentManager', ['$http', '$timeout', ($http, $timeout) ->
  restrict: 'A'
  scope: {     
    commentsType: '@' 
    commentsId: '@'
    commentCount: "=",
    commentsOpen: "="
    commentsEverOpened: "="
  }

  link: ($scope, $element, $attrs) ->

    $scope.$on 'toggleShowComments', ->
      $scope.commentsOpen = ! $scope.commentsOpen
      # Used with ng-if so we don't throw away the scope if they close it with an uncommitted comment. Also
      # let's them close and reopen the same one quickly.
      $scope.commentsEverOpened |= $scope.commentsOpen
      $scope.updateCommentCount()
      $rootScope.commentsShowing = $scope.commentsOpen
      true

    $scope.$on 'bodyClicked', ->
      $scope.toggleShowComments() if $scope.commentsOpen

    $scope.commentCount = -1
    $scope.updateCommentCount = ->
      identifier = $scope.commentsType + '_' + $scope.commentsId
      $http.get("http://server.usebloom.com/discussions/#{identifier}/count?apiKey=xchefsteps").success((data, status) ->
        $scope.commentCount = data["count"]
      )
    $timeout ->
      $scope.updateCommentCount()
]

