angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", ($scope,  $timeout) ->
  $scope.expandSocial = false;

  $scope.$on 'expandSocialButtons', ->
    $scope.expandSocial = true

  $scope.openSocialWindow = (url, spec) ->
    $scope.expandSocial = false
    window.open(url, "_blank", spec || "width=500, height=300, top=100, left=100")

  $scope.shareTwitter = (title, url) ->
    $scope.openSocialWindow "https://twitter.com/intent/tweet?text=I love this: " + title + " from @ChefSteps!&url=" + window.escape(url)
    mixpanel.track('Share', { 'Network': 'Twitter'})

  $scope.shareFacebook = (url) ->
    $scope.openSocialWindow "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent(url), 'width=626,height=436,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Facebook'})

  $scope.shareGooglePlus = (url) ->
    $scope.openSocialWindow "https://plus.google.com/share?url=" + encodeURIComponent(url), 'width=600,height=600,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Google Plus'})

  $scope.sharePinterest = (url, mediaURL) ->
    $scope.openSocialWindow "http://pinterest.com/pin/create/button/?url=" + encodeURIComponent(url) + "&media=" + encodeURIComponent(mediaURL), 'width=300,height=600,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Pinterest'})
]
