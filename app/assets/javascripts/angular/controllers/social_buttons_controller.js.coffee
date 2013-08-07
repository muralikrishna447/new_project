angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", "$http", ($scope,  $timeout, $http) ->
  $scope.expandSocial = false;

  $scope.$on 'expandSocialButtons', ->
    if $scope.split != "newNoPostPlay"
      $scope.expandSocial = true

  $scope.openSocialWindow = (url, spec) ->
    $scope.expandSocial = false
    window.open(url, "_blank", spec || "width=500, height=300, top=100, left=100")
    $http.put('/splitty/finished?experiment=social_share')

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

  $scope.shareEmail = (title, url) ->
    $scope.openSocialWindow "mailto:?subject="+ encodeURIComponent(title) + "%20from%20ChefSteps.com&body=I%20thought%20you%20might%20like%20this:%20" + encodeURIComponent(url)
    mixpanel.track('Share', { 'Network': 'Email'})

]

