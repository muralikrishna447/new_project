angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", "$http", ($scope,  $timeout, $http) ->
  $scope.expandSocial = false;

  $scope.$on 'expandSocialButtons', ->
    if $scope.split != "newNoPostPlay"
      $scope.expandSocial = true

  $scope.openSocialWindow = (url, spec) ->
    $scope.expandSocial = false
    window.open(url, "_blank", spec || "width=500, height=300, top=100, left=100")
    $http.put('/splitty/finished?experiment=social_share')

  $scope.shareTwitter = ->
    $scope.openSocialWindow "https://twitter.com/intent/tweet?text=" + $scope.tweetMessage() + " " + $scope.socialTitle() + " @ChefSteps!&url=" + window.escape($scope.socialURL())
    mixpanel.track('Share', { 'Network': 'Twitter', 'URL' : $scope.socialURL()})

  $scope.shareFacebook = ->
    $scope.openSocialWindow "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent($scope.socialURL()), 'width=626,height=436,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Facebook'})

  $scope.shareGooglePlus = ->
    $scope.openSocialWindow "https://plus.google.com/share?url=" + encodeURIComponent($scope.socialURL()), 'width=600,height=600,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Google Plus'})

  $scope.sharePinterest = ->
    $scope.openSocialWindow "http://pinterest.com/pin/create/button/?url=" + encodeURIComponent($scope.socialURL()) + "&media=" + encodeURIComponent($scope.socialMediaItem()), 'width=300,height=600,top=100,left=100'
    mixpanel.track('Share', { 'Network': 'Pinterest'})

  $scope.shareEmail = ->
    $scope.openSocialWindow "mailto:?subject="+ encodeURIComponent($scope.emailSubject()) + "&body=" + encodeURIComponent($scope.emailBody())
    mixpanel.track('Share', { 'Network': 'Email'})

]

