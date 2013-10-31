

angular.module('ChefStepsApp').controller 'SmokerController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "$anchorScroll", ($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, $anchorScroll) ->
  $scope.targetTemp = 85
  $scope.targetRH = 30
  $scope.smokeState = false
  $scope.fanState = true
  $scope.probe1Temp = "--"
  $scope.probe2Temp = "--"

  $scope.getState = ->
    $scope.loading = true
    $http.get("https://agent.electricimp.com/VfTPvDypa0TD?getState").success (data, status) ->
      $scope.state = data
      $timeout (-> $scope.loading = false), 500
      $timeout (-> $scope.getState()), 2000

  # boostrap the polling
  $scope.getState()

  $scope.$watch 'targetTemp', ((newValue, oldValue) ->
    if newValue != oldValue
      console.log "setting temp " + newValue
      $http.get("https://agent.electricimp.com/VfTPvDypa0TD?temperatureSetPoint=" + newValue).error (data, status) ->
        console.log(data)
  )

  $scope.$watch 'targetRH', ((newValue, oldValue) ->
    if newValue != oldValue
      console.log "setting temp " + newValue
      $http.get("https://agent.electricimp.com/VfTPvDypa0TD?humiditySetPoint=" + newValue).error (data, status) ->
        console.log(data)
  )

  $scope.colorClass = (v1, v2) ->
    return "tooLow" if v1 > v2
    return "tooHigh" if v1 < v2
    return "justRight"
]
