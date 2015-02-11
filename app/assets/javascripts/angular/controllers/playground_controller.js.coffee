@app.controller 'PlaygroundController', ['$scope', '$http', ($scope, $http) ->
  $scope.user = {}
  $scope.getTokenStatus = null
  $scope.getToken = (user) ->
    $http.post('https://staging2-chefsteps.herokuapp.com/api/v0/authenticate', $.param({user: $scope.user}), {
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

  $scope.testTokenStatus = null
  $scope.testToken = (token) ->
    $http.get(
      'https://staging2-chefsteps.herokuapp.com/api/v0/users'
      headers: { 'Authorization': 'Bearer ' + token }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.testTokenStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.testTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.newUser = {}
  $scope.createUserStatus = null
  $scope.createUser = (newUser) ->
    $http.post(
      '/api/v0/users'
      {user: $scope.newUser}
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.createUserStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.createUserStatus = "Error: #{JSON.stringify(data)}"

  $scope.forgetfulUser = {}
  $scope.resetPasswordStatus = null
  $scope.resetPassword = (forgetfulUser) ->
    $http.post(
      '/api/v0/passwords/reset'
      {email: forgetfulUser.email}
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.resetPasswordStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.resetPasswordStatus = "Error: #{JSON.stringify(data)}"

  $scope.clear = ->
    $scope.user = {}
    $scope.newUser = {}
    $scope.forgetfulUser = {}
    $scope.getTokenStatus = null
    $scope.testTokenStatus = null
    $scope.createUserStatus = null
]