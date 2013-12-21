angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", ($scope, $http) ->
  $scope.inputs = 
    waterTemp: 50
    desiredViscosity: 16
    diameter: 46.60
    startTemp: 5
    surfaceHeatTransferCoefficient: 155
    beta: 1.7

  $scope.output = "[not calculated]"

  $scope.update = ->
    $scope.loading = true
    $http.get("http://gentle-taiga-4435.herokuapp.com/egg_time").success (data, status) ->
      $scope.output = data
      $scope.loading = false


  $scope.$watch 'inputs.waterTemp', ((newValue, oldValue) ->
    if newValue != oldValue
      $scope.update()
  )

]
