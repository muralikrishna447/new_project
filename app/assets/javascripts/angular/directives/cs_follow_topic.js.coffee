@app.directive 'csFollowTopic', [ "csAuthentication", (csAuthentication) ->
  restrict: 'A'
  scope: { topic: "@", text: "@"}

  link: ($scope, $element, $attrs) ->

    $scope.followed = false

    followTopic = ->
      mixpanel.track 'Topic Followed', { topic: $scope.topic }
      $scope.followed = true

    $scope.tryFollowTopic = ->
      if csAuthentication.loggedIn()
        followTopic()
      else
        $scope.$on 'login', -> followTopic()
        $scope.$emit 'openSignupModal', 'followTopicButton', 'none'

  template: """
    <div>
      <div class="btn btn-primary" ng-click="tryFollowTopic()">
        {{text}}
        <i class="icon icon-large icon-check" ng-show="followed"/>
      </div>
    </div>
  """
]
