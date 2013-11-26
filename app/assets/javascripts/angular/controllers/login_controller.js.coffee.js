angular.module('ChefStepsApp').controller 'LoginController', ($scope, $http) ->
  $scope.dataLoading = 0
  $scope.login_user = {email: null, password: null};
  $scope.login_error = {message: null, errors: {}};
  $scope.register_user = {email: null, password: null, password_confirmation: null};
  $scope.register_error = {message: null, errors: {}};

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static'}

  $scope.loginModalOpen = false

  $scope.openModal = ->
    $scope.loginModalOpen = true

  $scope.closeModal = ->
    $scope.loginModalOpen = false

  $scope.login = ->
    $scope.submit(
      method: 'POST'
      url: '/users/sign_in.json'
      data:
        user:
          email: $scope.login_user.email
          password: $scope.login_user.password
      success_message: "You have been logged in."
      error_entity: $scope.login_error
    )

  $scope.logout = ->
    $scope.submit(
      method: 'DELETE'
      url: '/users/sign_out.json'
      success_message: "You have been logged out."
      error_entity: $scope.login_error
    )

  $scope.password_reset = ->
    $scope.submit(
      method: 'POST'
      url: '/users/password/new.json'
      data:
        user:
          email: $scope.login_user.email
      success_message: "Reset instructions have been sent to your e-mail address."
      error_entity: $scope.login_error
    )

  $scope.register = ->
    $scope.submit(
      method: 'POST'
      url: '/users.json'
      data:
        user:
          email: $scope.register_user.email
          password: $scope.register_user.password
          password_confirmation: $scope.register_user.password_confirmation
      success_message: "You have been registered and logged in.  A confirmation e-mail has been sent to your e-mail address, your access will terminate in 2 days if you do not use the link in that e-mail."
      error_entity: $scope.register_error)

  $scope.change_password = ->
    $scope.submit(
      method: 'PUT'
      url: '/users/password.json'
      data: {user: {email: $scope.register_user.email
        password: $scope.register_user.password
        password_confirmation: $scope.register_user.password_confirmation}}
      success_message: "Your password has been updated."
      error_entity: $scope.register_error)

  $scope.submit = (parameters) ->
    $scope.dataLoading += 1
    $scope.reset_messages();

    $http(
      method: parameters.method,
      url: parameters.url,
      data: parameters.data
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.message = parameters.success_message
          $scope.logged_in = true
        else if (status == 201 || status == 204)
          parameters.error_entity.message = parameters.success_message;
          $scope.reset_users();
        else
          if (data.error)
            parameters.error_entity.message = data.error;
          else
            parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 422 || status == 401)
          parameters.error_entity.message = data.errors;
        else
          if (data.error)
            parameters.error_entity.message = data.error;
          else
            parameters.error_entity.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )

  $scope.reset_messages = ->
    $scope.login_error.message = null;
    $scope.login_error.errors = {};
    $scope.register_error.message = null;
    $scope.register_error.errors = {};

  $scope.reset_users = ->
    $scope.login_user.email = null;
    $scope.login_user.password = null;
    $scope.register_user.email = null;
    $scope.register_user.password = null;
    $scope.register_user.password_confirmation = null;
