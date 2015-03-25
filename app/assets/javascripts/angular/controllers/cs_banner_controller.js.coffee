@app.controller 'csBannerSignupController', ['$scope', 'csAuthentication', ($scope, csAuthentication) ->
  @include = !csAuthentication.currentUser()
  @dismissed = false

  @signup = ->
    mixpanel.track 'Banner Signup Clicked'
    $scope.dismissed = true
    $scope.$emit 'openSignupModal', 'ActivityBanner'

  @dismiss = ->
    mixpanel.track 'Banner Dismissed'
    $scope.dismissed = true

  if $scope.include
    mixpanel.track 'Banner Signup Shown'
]