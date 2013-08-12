angular.module('ChefStepsApp').controller 'PollItemController', ["$scope", "$timeout", ($scope, $timeout) ->

  $scope.expandSocial =  ->
    $timeout (->
      $scope.videoDurationExceeded = true
      $scope.$broadcast('expandSocialButtons')
    ), 1500

  $scope.socialTitle = ->
    $scope.poll_item.title

  $scope.socialMediaItem = ->
    null

  $scope.tweetMessage = ->
    "Vote for"

  $scope.emailSubject = ->
    "Vote for " + $scope.socialTitle()

  $scope.emailBody = ->
    "Hey, will you come vote for " + $scope.socialTitle() + " at ChefSteps.com? Here's the link: " + $scope.socialURL()

]