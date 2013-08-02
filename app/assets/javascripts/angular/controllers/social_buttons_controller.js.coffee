angular.module('ChefStepsApp').controller 'SocialButtonsController', ["$scope",  "$timeout", ($scope,  $timeout) ->
  $scope.expandSocial = false;

  $scope.$on 'expandSocialButtons', ->
    $scope.expandSocial = true

]
