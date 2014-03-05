angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", "$scope", ($rootScope, $scope) ->

  $scope.getTotalUsers = ->
    $rootScope.getTotalUsers() || 36297
]