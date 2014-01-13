angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", "$timeout", ($scope, $http, $timeout) ->

  $scope.states = [
    { name: "white", next: "yolk"}
    { name: "yolk", prev: "white", next: "results" }
    { name: "results", prev: "yolk", secondary: "rate"}
    { name: "rate", next: "thanks"}
    { name: "size", next: "results", secondary: "startTemp"}
    { name: "startTemp", next: "results", secondary: "bathType"}
    { name: "bathType", next: "results"}
  ]

  $scope.state = $scope.states[0]

  $scope.inputs = 
    water_temp: 70
    desired_viscosity: 16
    diameter: 43
    start_temp: 5
    surface_heat_transfer_coeff: 135
    beta: 1.7

  $scope.formatTime = (t, showSeconds) ->
    h = Math.floor(t / 3600)
    t = t - (h * 3600)
    m = Math.floor(t / 60)
    t = t - (m * 60)
    s = Math.floor(t)
    m += 1 if (s >= 30) && (! showSeconds)

    result = ""
    result += "#{h} hours, " if h > 0
    result += "#{m} mins"
    if showSeconds
      # Force a non-zero second so user knows we need precision
      s = 1 if s == 0 
      result += ", #{s} secs"
    result

  $scope.viscosityToDescriptor = (v) ->
    return "syrup" if v <= 8
    return "mayonnaise" if v <= 12.5
    return "pudding" if v <= 18
    return "honey" if v <= 26
    return "icing"

  $scope.update = ->
    $scope.loading = true
    $http.get("http://gentle-taiga-4435.herokuapp.com/egg_time/", params: $scope.inputs).success((data, status) ->
      $scope.output = data
      $scope.loading = false
      $scope.$apply() if ! $scope.$$phase
      console.log(data.items[1])
    ).error((data, status, headers, config) ->
      debugger
    )

  $scope.throttledUpdate = 
    _.throttle($scope.update, 250)

  $scope.$watchCollection 'inputs', -> 
    $scope.throttledUpdate()

  findState = (name) ->
    _.find($scope.states, (x) -> x.name == name)

  $scope.getPrevState = ->
    findState($scope.state.prev)

  $scope.getNextState = ->
    findState($scope.state.next)

  $scope.goPrevState = ->
    $scope.state = $scope.getPrevState()

  $scope.goNextState = ->
    $scope.state = $scope.getNextState()

  $scope.goState = (name) ->
    $scope.state = findState(name)

]
