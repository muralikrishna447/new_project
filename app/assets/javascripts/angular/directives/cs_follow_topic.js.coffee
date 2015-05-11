@app.directive 'csFollowTopic', [ "csAuthentication", (csAuthentication) ->
  restrict: 'A'
  scope: { topic: "@", text: "@"}

  link: ($scope, $element, $attrs) ->

    $scope.followed = false

    followTopic = ->
      # This would be better as a custom user attribute instead of an event,
      # however that would require fetching the User and updating it to avoid
      # trashing old values, and the pieces of API we need for that aren't in
      # the Intercom JS API, so we'd either need to build that including auth,
      # or add intermediate code on the Rails side. More work than it is worth
      # for this quick test, but worth doing if this becomes a "thing".
      mixpanel.track 'Topic Followed', { topic: $scope.topic }
      Intercom?('trackEvent', "Follow #{$scope.topic}");
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
