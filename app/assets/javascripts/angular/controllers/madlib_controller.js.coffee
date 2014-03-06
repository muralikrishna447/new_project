angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $rootScope.splits.includeSocialInMadlib = Math.random() > 0.5

  $scope.getTotalUsers = ->
    $rootScope.getTotalUsers() || 36297
]