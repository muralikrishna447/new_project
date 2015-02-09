@app.controller 'PlaygroundController', ['$scope', 'api.activity', '$sce', '$http', ($scope, Activity, $sce, $http) ->

  $scope.activity = Activity.get({id: 'beef-tartare'})
  $scope.getTokenStatus = null
  $scope.testTokenStatus = null

  $scope.getToken = (user) ->
    $http.post('/api/v0/authenticate', $.param({user: $scope.user}), {
      headers: {
        "content-type" : "application/x-www-form-urlencoded"
      }
    }).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getTokenStatus = "Success: #{JSON.stringify(data)}"
      $scope.user.token = data.token
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.getTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.testToken = (token) ->
    $http(
      method: 'GET'
      url: '/api/v0/users'
      headers: {
        'Authorization': token
      }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.testTokenStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.testTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.clear = ->
    $scope.getTokenStatus = null
    $scope.testTokenStatus = null
]