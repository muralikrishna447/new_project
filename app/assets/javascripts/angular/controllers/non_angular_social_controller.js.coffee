# This is a little adapter for the modern angularized social controller so that it can get
# its info from rails instead of from the scope. See how it is called using ng-init.

angular.module('ChefStepsApp').controller 'NonAngularSocialController', ["$scope", "$timeout", ($scope, $timeout) ->

  $scope.socialURL = ->
    $scope.url

  $scope.socialTitle = ->
    $scope.title

  $scope.socialMediaItem = ->
    $scope.media

  $scope.tweetMessage = ->
    "Check out"

  $scope.emailSubject = ->
    "Check out " + $scope.socialTitle()

  $scope.emailBody = ->
    "Hey, I thought you might like " + $scope.socialTitle() + " at ChefSteps.com. Here's the link: " + $scope.socialURL()

]