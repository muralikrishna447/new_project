# Usage Example:
# %div(ng-controller='csBannerSignupController as banner' ng-init="banner.source = 'ActivityFooter'")

@app.controller 'csBannerSignupController', ['$scope', 'csAuthentication', ($scope, csAuthentication) ->
  @show = !csAuthentication.currentUser()

  @signup = ->
    mixpanel.track 'Banner Signup Clicked'
    @dismissed = true
    $scope.$emit 'openSignupModal', @source

  @dismiss = ->
    mixpanel.track 'Banner Dismissed'
    @dismissed = true

  if @show
    mixpanel.track 'Banner Signup Shown'

  return this
]