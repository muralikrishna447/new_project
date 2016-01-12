@app.controller 'PlaygroundController', ['$scope', '$http', ($scope, $http) ->
  # Host can be set to a different url as needed
  host = ""
  $scope.user = {}
  $scope.getTokenStatus = null
  $scope.getToken = (user) ->
    $http.post(
      host + '/api/v0/authenticate'
      $.param({user: $scope.user})
      headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getTokenStatus = "Success: #{JSON.stringify(data)}"
      $scope.user.token = data.token
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.getTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.logout = (token) ->
    $http.post(
      host + '/api/v0/logout'
      {}
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.logoutStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.logoutStatus = "Error: #{JSON.stringify(data)}"

  $scope.getTokenFacebookStatus = null
  $scope.getTokenFacebook = (user) ->
    user = {}
    status = window.facebookResponse.status
    if status == 'connected'
      # Existing user who has already connected with Facebook
      user = window.facebookResponse.user
      FB.api '/me', (meResponse) ->
        console.log "meResponse: "
        console.log meResponse
        user.name = meResponse.first_name + ' ' + meResponse.last_name
        user.email = meResponse.email
        console.log 'HERE IS THE USER'
        console.log user
        $http.post(
          host + '/api/v0/authenticate_facebook'
          $.param({user: user})
          headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined }
        ).success((data, status, headers, cfg) ->
          console.log "success: "
          console.log data
          $scope.getTokenFacebookStatus = "Success: #{JSON.stringify(data)}"
          $scope.user.token = data.token
        ).error (data, status, headers, cfg) ->
          console.log "error: "
          console.log data
          $scope.getTokenFacebookStatus = "Error: #{JSON.stringify(data)}"
        $scope.$apply()
    else
      # New user from Facebook, so we'll create an account for them
      FB.login ( (loginResponse) ->
        if loginResponse.authResponse
          console.log 'loginResponse: '
          console.log loginResponse
          user.authentication_token = loginResponse.authResponse.accessToken
          user.user_id = loginResponse.authResponse.userID
          user.provider = "facebook"
          FB.api '/me', (meResponse) ->
            console.log "meResponse: "
            console.log meResponse
            user.name = meResponse.first_name + ' ' + meResponse.last_name
            user.email = meResponse.email
            console.log "user: "
            console.log user
            $http.post(
              host + '/api/v0/users'
              $.param({user: user})
              headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined }
            ).success((data, status, headers, cfg) ->
              console.log "success: "
              console.log data
              $scope.getTokenFacebookStatus = "Success: #{JSON.stringify(data)}"
            ).error (data, status, headers, cfg) ->
              console.log "error: "
              console.log data
              $scope.getTokenFacebookStatus = "Error: #{JSON.stringify(data)}"
            $scope.$apply()
      ), {scope: 'email'}

  $scope.validateTokenStatus = null
  $scope.validateToken = (serviceToken, token) ->
    $http.get(
      host + '/api/v0/validate'
      headers: { 'Authorization': 'Bearer ' + serviceToken, "x-csrf-token":undefined }
      params: {token: token}
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.validateTokenStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.validateTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.getMeStatus = null
  $scope.getMe = (token) ->
    $http.get(
      host + '/api/v0/users/me'
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getMeStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.getMeStatus = "Error: #{JSON.stringify(data)}"

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

  $scope.userToUpdate = {}
  $scope.updateUserStatus = null
  $scope.updateUserData = {}
  $scope.updateUser = (userToUpdateData) ->
    $http.put(
      host + '/api/v0/users/' + $scope.updateUserData.id
      $.param({user: $scope.userToUpdate})
      headers: { "Content-Type" : "application/x-www-form-urlencoded", 'Authorization': 'Bearer ' + $scope.updateUserData.token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.updateUserStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.updateUserStatus = "Error: #{JSON.stringify(data)}"

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
      host + '/api/v0/passwords/send_reset_email'
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

  $scope.externalRedirectStatus = null
  $scope.externalRedirect = (token, path) ->
    $http.get(
      host + "/api/v0/auth/external_redirect",
      params: {path: path}
      headers: { 'Authorization': 'Bearer ' + token }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.externalRedirectStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.externalRedirectStatus = "Error: #{JSON.stringify(data)}"

  $scope.clear = ->
    $scope.user = {}
    $scope.circulator = {}
    $scope.newUser = {}
    $scope.forgetfulUser = {}
    $scope.getTokenStatus = null
    $scope.testTokenStatus = null
    $scope.listCirculatorsStatus = null
    $scope.createCirculatorStatus = null
    $scope.deleteCirculatorStatus = null
    $scope.createUserStatus = null
    $scope.getActivitiesStatus = null
    $scope.getTokenFacebookStatus = null
    $scope.getMeStatus = null
    $scope.validateTokenStatus = null
    $scope.userToUpdate = {}
    $scope.updateUserStatus = null
    $scope.updateUserData = {}

  $scope.getActivities = ->
    $http.get(
      host + '/api/v0/activities'
      headers: { "x-csrf-token":undefined }
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

  $scope.getCirculatorsStatus = null
  $scope.getCirculators = (token) ->
    $http.get(
      host + '/api/v0/circulators'
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getCirculatorsStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.getCirculatorsStatus = "Error: #{JSON.stringify(data)}"

  $scope.createCirculatorStatus = null
  $scope.createCirculator = (token, circulatorId, serialNumber, notes) ->
    $http.post(
      host + '/api/v0/circulators',
      {circulator: {id: circulatorId, serial_number: serialNumber, notes: notes}},
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.createCirculatorStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.createCirculatorStatus = "Error: #{JSON.stringify(data)}"

  $scope.getCirculatorTokenStatus = null
  $scope.getCirculatorToken = (token, circulatorId) ->
    $http.get(
      host + "/api/v0/circulators/#{circulatorId}/token",
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.getCirculatorTokenStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.getCirculatorTokenStatus = "Error: #{JSON.stringify(data)}"

  $scope.deleteCirculatorStatus = null
  $scope.deleteCirculator = (token, id) ->
    $http.delete(
      host + '/api/v0/circulators/' + id,
      headers: { 'Authorization': 'Bearer ' + token, "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.deleteCirculatorStatus = "Success: #{JSON.stringify(data)}"
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      console.log headers
      $scope.deleteCirculatorStatus = "Error: #{JSON.stringify(data)}"


]
