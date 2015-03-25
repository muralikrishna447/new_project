@app.controller 'csBannerController', ['$scope', ($scope) ->
  $scope.banner = {}

  $scope.banner.dismissed = false

  $scope.dismiss = ->
    mixpanel.track 'Banner Dismissed'
    $scope.banner.dismissed = true

]

@app.controller 'csBannerSignupController', ['$scope', 'csAuthentication', ($scope, csAuthentication) ->
  $scope.includeBanner = !csAuthentication.currentUser()

  $scope.signup = ->
    mixpanel.track 'Banner Signup Clicked'
    $scope.$emit 'openSignupModal', 'ActivityBanner'

  if $scope.includeBanner
    mixpanel.track 'Banner Signup Shown'
]