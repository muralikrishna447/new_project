angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", "$http", ($scope,  $timeout, $http) ->
  $scope.expandSocial = false;

  $scope.$on 'expandSocialButtons', ->
    $scope.expandSocial = true

  $scope.openSocialWindow = (mixpanel_name, url, spec) ->
    $scope.expandSocial = false
    window.open(url, "_blank", spec || "width=500, height=300, top=100, left=100")
    $http.put('/splitty/finished?experiment=social_share_cta')
    share_cat = $scope.socialURL().split("/")[3]
    mixpanel.track('Share', { 'Network': mixpanel_name, 'URL' : $scope.socialURL(), 'ShareCat' : share_cat})

  $scope.shareTwitter = ->
    $scope.openSocialWindow 'Twitter', "https://twitter.com/intent/tweet?text=" + $scope.tweetMessage() + " " + $scope.socialTitle() + " @ChefSteps!&url=" + window.escape($scope.socialURL())

  $scope.shareFacebook = ->
    $scope.openSocialWindow 'Facebook', "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent($scope.socialURL()), 'width=626,height=436,top=100,left=100'

  $scope.shareGooglePlus = ->
    $scope.openSocialWindow 'Google Plus', "https://plus.google.com/share?url=" + encodeURIComponent($scope.socialURL()), 'width=600,height=600,top=100,left=100'

  $scope.sharePinterest = ->
    $scope.openSocialWindow 'Pinterest', "http://pinterest.com/pin/create/button/?url=" + encodeURIComponent($scope.socialURL()) + "&media=" + encodeURIComponent($scope.socialMediaItem()), 'width=300,height=600,top=100,left=100'

  $scope.shareEmail = ->
    $scope.openSocialWindow 'Email', "mailto:?subject="+ encodeURIComponent($scope.emailSubject()) + "&body=" + encodeURIComponent($scope.emailBody())

]

