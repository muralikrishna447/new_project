angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", ($scope, $http) ->
  $scope.inputs = 
    water_temp: 70
    desired_viscosity: 16
    diameter: 46.60
    start_temp: 5
    surface_heat_transfer_coefficient: 155
    beta: 1.7

  $scope.formatTime = (t) ->
    m = Math.floor(t/60)
    s = String(Math.floor(t - m * 60))
    if s.length == 1
      s = "0" + s
    return "#{m}:#{s}"


  $scope.update = ->
    $scope.loading = true
    $http.get("http://gentle-taiga-4435.herokuapp.com/egg_time/", params: $scope.inputs).success((data, status) ->
      $scope.output = data
      $scope.loading = false
      console.log(data.items[1])
    ).error((data, status, headers, config) ->
      debugger
    )

 
  $scope.$watch 'inputs.water_temp', -> $scope.update()
  $scope.$watch 'inputs.desired_viscosity', -> $scope.update()
  $scope.$watch 'inputs.diameter', -> $scope.update()
  $scope.$watch 'inputs.start_temp', -> $scope.update()
  $scope.$watch 'inputs.surface_heat_transfer_coefficient', -> $scope.update()
  $scope.$watch 'inputs.beta', -> $scope.update()

]
