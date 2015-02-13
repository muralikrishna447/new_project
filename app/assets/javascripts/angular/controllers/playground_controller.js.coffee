@app.controller 'PlaygroundController', ['$scope', '$http', ($scope, $http) ->
  # host = 'http://localhost:3000'
  host = '//delve:howtochef22@staging2-chefsteps.herokuapp.com'
  $scope.user = {}
  $scope.getTokenStatus = null
  $scope.getToken = (user) ->
    $http.post(
      host + '/api/v0/authenticate'
      $.param({user: $scope.user})
      headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined, 'Authentication': 'Basic ZGVsdmU6aG93dG9jaGVmMjI=' }
    ).success((data, status, headers, cfg) ->
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
      host + '/api/v0/users'
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
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
      host + '/api/v0/users'
      $.param({user: $scope.newUser})
      headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined }
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
      headers: { "x-csrf-token":undefined }
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
    $scope.getActivitiesStatus = null

  $scope.getActivities = ->
    console.log "HOST IS: #{host}"
    $http.get(
      host + '/api/v0/activities'
      headers: { "x-csrf-token":undefined, 'Authentication': 'Basic ZGVsdmU6aG93dG9jaGVmMjI=' }
      withCredentials: true
      transformRequest: (data, headersGetter) ->
        headers = headersGetter()
        console.log "headers:"
        console.log headers
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getActivitiesStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log "status: "
      console.log status
      console.log "headers: "
      console.log headers()
      console.log "config: "
      console.log cfg
      $scope.getActivitiesStatus = "Error: #{JSON.stringify(data)}"
]