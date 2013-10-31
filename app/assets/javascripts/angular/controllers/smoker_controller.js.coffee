angular.module('ChefStepsApp').controller 'SmokerController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "$anchorScroll", ($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, $anchorScroll) ->
  $scope.currentTemp = 80
  $scope.targetTemp = 85
  $scope.currentRH = 20
  $scope.targetRH = 30
  $scope.smokeState = false
  $scope.fanState = true
  $scope.probe1Temp = 63
  $scope.probe2Temp = 50
]
