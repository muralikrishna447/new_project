angular.module('ChefStepsApp').controller 'MadlibController', ["$rootScope", ($rootScope) ->
  $rootScope.splits.showMadlibCount = Math.random() > 0.5
]