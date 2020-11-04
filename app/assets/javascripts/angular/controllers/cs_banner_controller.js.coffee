# Usage Example:
# .cs-banner.banner-signup(ng-controller='csBannerSignupController as banner'
#                                         ng-show='banner.show'
#                                         ng-class="{true:'inactive', false: 'active'}[banner.dismissed]"
#                                         ng-init="banner.source = 'ActivityBanner'"
#                                         ng-cloak
#                                         )
#   .cs-banner-msg
#     %h3 Sign up for the latest recipes and techniques.
#   .cs-banner-cta(ng-click='banner.signup()')
#     Join
#   .cs-banner-close(ng-click='banner.dismiss()')
#     %i(cs-icon='x')

@app.controller 'csBannerSignupController', ['$scope', 'csAuthentication', ($scope, csAuthentication) ->
  @show = !csAuthentication.currentUser()

  @signup = ->
    @dismissed = true
    $scope.$emit 'openSignupModal', @source

  @dismiss = ->
    @dismissed = true

  return this
]
