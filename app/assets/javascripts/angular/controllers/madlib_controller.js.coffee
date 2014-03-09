angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $rootScope.splits.includeSocialInMadlib2 = Math.random() > 0.5

  $scope.getTotalUsers = ->
    $rootScope.getTotalUsers() || 36297
]