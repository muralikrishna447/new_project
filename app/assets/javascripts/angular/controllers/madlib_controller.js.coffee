angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $scope.getTotalUsers = ->
    $scope.totalUsers || 36297
]