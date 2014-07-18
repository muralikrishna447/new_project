@app.directive 'cscomments', ["$compile", "$rootScope", ($compile, $rootScope) ->
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
    $scope.openLogin = ->
      $scope.$emit 'openLoginModal'
      $scope.$apply()
  ]
  link: (scope, element, attrs) ->

    scope.$watch 'commentsId', (newValue, oldValue) ->
      if newValue
        if scope.seoBot == 'true'
          scope.renderSeoComments()
        else
          identifier = scope.commentsType + '_' + scope.commentsId
          # Hack so that it doesn't install multiple iframes
          iframe = element[0].getElementsByTagName('iframe')
          if iframe.length > 0
            console.log "HERE IS THE ELEMENT"
            console.log element[0]
            angular.forEach iframe, (frame) ->
              frame.remove()
          Bloom.installComments {
            el: element[0]
            discussionId: identifier
            on:
              login: ->
                scope.openLogin()
          }
    $rootScope.$on 'reloadComments', (event) ->
      window.location.reload()

  template: "<div>{{seoComments}}</div>"
]

@app.directive 'csnotifs', [ ->
  restrict: 'E'
  scope: {
    'navigateToContent': '&navigateToContent'
  }
  controller: [ "$scope", "$http", ($scope, $http) ->
    $scope.navigateToContent = (commentsId)->
      url = '/comments/info?commentsId=' + commentsId
      $http.get(url).then (response) ->
        window.location = response.data.url
  ]
  link: (scope, element, attrs) ->
    Bloom.installNotifs {
      el: element[0]
      on:
        navigateComment: (comment) ->
          console.log 'navigation to comment: ', comment.dbParams.commentsId
          scope.navigateToContent(comment.dbParams.commentsId)
    }
]

