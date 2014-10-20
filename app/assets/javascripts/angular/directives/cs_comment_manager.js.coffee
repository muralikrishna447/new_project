@app.directive 'csCommentManager', ['$http', '$timeout', '$rootScope', ($http, $timeout, $rootScope) ->
  restrict: 'EA'
  templateUrl: '/client_views/cs_comment_manager'
  scope: {     
    commentsType: '@' 
    commentsId: '@'
    seoBot: '@'
    showWhenZero: '@'
  }

  link: ($scope, $element, $attrs) ->
    $scope.commentCount = -1
    $scope.commentsOpen = false
    $scope.commentsEverOpened = false

    $scope.toggleShowComments = ($event) ->
      $scope.commentsOpen = ! $scope.commentsOpen
      # Used with ng-if so we don't throw away the scope if they close it with an uncommitted comment. Also
      # let's them close and reopen the same one quickly.
      $scope.commentsEverOpened |= $scope.commentsOpen
      $scope.updateCommentCount()
      $rootScope.commentsShowing = $scope.commentsOpen
      $event.stopPropagation() if $event
      true

    $scope.$on 'bodyClicked', ->
      $scope.toggleShowComments() if $scope.commentsOpen

    $scope.updateCommentCount = ->
      identifier = $scope.commentsType + '_' + $scope.commentsId
      $http.get("http://server.usebloom.com/discussions/#{identifier}/count?apiKey=xchefsteps").success((data, status) ->
        $scope.commentCount = data["count"]
      )

    # First time
    $scope.updateCommentCount()
]

