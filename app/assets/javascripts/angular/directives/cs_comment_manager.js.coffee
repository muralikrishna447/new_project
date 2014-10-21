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
      $rootScope.commentsShowing = $scope.commentsOpen = ! $scope.commentsOpen
      $scope.updateCommentCount()

      # Used with ng-if so we don't throw away the scope if they close it with an 
      # uncommitted comment. Also let's them close and reopen the same one quickly.
      $scope.commentsEverOpened |= $scope.commentsOpen

      slide = $element.closest('.comments-slide')
      if slide
        if $scope.commentsOpen
          # document.documentElement.clientWidth was wrong in classes... why?
          viewRight = window.innerWidth || document.documentElement.clientWidth
          rightMargin = if viewRight > 320 then 23 else 20
          myRight = $element.find('.comment-container')[0].getBoundingClientRect().right + rightMargin
          slide.animate({'left': Math.min(viewRight - myRight, 0)})
        else
          slide.animate({'left': 0})

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

