

angular.module('ChefStepsApp').controller 'SmokerController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "$anchorScroll", ($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, $anchorScroll) ->
  $scope.targetTemp = 85
  $scope.targetRH = 30
  $scope.smokeState = false
  $scope.fanState = true
  $scope.probe1Temp = 63
  $scope.probe2Temp = 50

  $scope.getState = ->
    $http.get("https://agent.electricimp.com/VfTPvDypa0TD?getState").success (data, status) ->
      $scope.state = data
      $timeout (-> $scope.getState()), 1000

  $scope.getState()

  $scope.colorClass = (v1, v2) ->
    return "tooLow" if v1 > v2
    return "tooHigh" if v1 < v2
    return "justRight"
]
