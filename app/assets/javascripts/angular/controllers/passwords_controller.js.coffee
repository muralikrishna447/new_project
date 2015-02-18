@app.controller 'PasswordsController', ['$scope', '$http', '$location', ($scope, $http, $location) ->
  $scope.token = $location.search().token
  $scope.updateFromEmailStatus = {}
  $scope.updateFromEmail = () ->
    $http.post(
      '/api/v0/passwords/update_from_email'
      $.param({password: $scope.password, token: $scope.token})
      headers: { "Content-Type" : "application/x-www-form-urlencoded", "x-csrf-token":undefined }
    ).success((data, status, headers, cfg) ->
      console.log "success: "
      console.log data
      $scope.updateFromEmailStatus.status = 'success'
      $scope.updateFromEmailStatus.message = 'Your password was successfully updated!'
    ).error (data, status, headers, cfg) ->
      console.log "error: "
      console.log data
      $scope.updateFromEmailStatus.status = 'error'
      $scope.updateFromEmailStatus.message = 'There was an error while saving your password.'

  $scope.alertClass = ->
    'alert-' + $scope.updateFromEmailStatus.status
]