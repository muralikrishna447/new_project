angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $rootScope.splits.oddMadlibCount = Math.random() > 0.5

  $scope.getTotalUsers = ->
    if $rootScope.splits.oddMadlibCount
      $rootScope.getTotalUsers() || 36297
    else
      36000
]