angular.module('ChefStepsApp').controller 'LoginController', ($scope, $http, csAuthentication) ->
  $scope.dataLoading = 0
  $scope.login_user = {email: null, password: null};
  $scope.login_error = {message: null, errors: {}};
  $scope.register_user = {email: null, password: null, password_confirmation: null};
  $scope.register_error = {message: null, errors: {}};

  $scope.showForm = "signIn" # For switching between signUp and signIn.

  $scope.authentication = csAuthentication # Authentication service

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static'}

  $scope.loginModalOpen = false

  $scope.passwordType = "password" # Defaults password to the password input type, but lets it switch to just text

  $scope.hasError = (error) ->
    if error
      "error"
    else
      "clean"

  $scope.switchForm = (form) ->
    $scope.showForm = form

  # $scope.notifyLogin = (user) ->
  #   $scope.closeModal()
  #   user = $.parseJSON(user) if typeof(user) == "string"
  #   $scope.$emit "loginSuccessful", {user: user}

  $scope.openModal = ->
    $scope.loginModalOpen = true

  $scope.closeModal = ->
    $scope.loginModalOpen = false

  $scope.togglePassword = ->
    if $scope.passwordType == "password"
      $scope.passwordType = "text"
    else
      $scope.passwordType = "password"

  $scope.login = ->
    $scope.dataLoading += 1
    $scope.resetMessages()
    $http(
      method: 'POST'
      url: '/users/sign_in.json'
      data:
        user:
          email: $scope.login_user.email
          password: $scope.login_user.password
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.message = "You have been signed in."
          $scope.logged_in = true
          $scope.closeModal()
          setTimeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.setCurrentUser(data.user)
          , 100)
          # $scope.notifyLogin(data.user)

        else
          if (data.error)
            $scope.message = data.error
          else
            $scope.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1
        if (data.errors)
          $scope.message = data.errors
        else
          $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data)
      )


  $scope.logout = ->
    $scope.dataLoading += 1
    $scope.resetMessages();

    $http(
      method: 'DELETE'
      url: '/users/sign_out.json'
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.message = "You have been logged out."
          $scope.logged_in = false
          $scope.closeModal()
          setTimeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.clearCurrentUser()
          , 100)
        else
          if (data.error)
            $scope.message = data.error;
          else
            $scope.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 422 || status == 401)
          $scope.message = data.errors;
        else
          if (data.error)
            $scope.message = data.error;
          else
            $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )

  # $scope.password_reset = ->
  #   $scope.submit(
  #     method: 'POST'
  #     url: '/users/password/new.json'
  #     data:
  #       user:
  #         email: $scope.login_user.email
  #     success_message: "Reset instructions have been sent to your e-mail address."
  #     error_entity: $scope.login_error
  #   )

  $scope.register = ->
    $scope.dataLoading += 1
    $scope.resetMessages();

    $http(
      method: 'POST'
      url: '/users.json'
      data:
        user:
          name: $scope.register_user.name
          email: $scope.register_user.email
          password: $scope.register_user.password
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.logged_in = true
          $scope.closeModal()
          $scope.message = "You have been registered and logged in."
          setTimeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.setCurrentUser(data.user)
          , 100)
          # $scope.notifyLogin(data.user)
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 401)
          $scope.message = data.info;
          $scope.register_error.errors = data.errors
        else
          $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )

  # $scope.change_password = ->
  #   $scope.submit(
  #     method: 'PUT'
  #     url: '/users/password.json'
  #     data: {user: {email: $scope.register_user.email
  #       password: $scope.register_user.password
  #       password_confirmation: $scope.register_user.password_confirmation}}
  #     success_message: "Your password has been updated."
  #     error_entity: $scope.register_error)

  # $scope.submit = (parameters) ->
  #   $scope.dataLoading += 1
  #   $scope.resetMessages();

  #   $http(
  #     method: parameters.method,
  #     url: parameters.url,
  #     data: parameters.data
  #     )
  #     .success( (data, status) ->
  #       $scope.dataLoading -= 1
  #       if (status == 200)
  #         $scope.message = parameters.success_message
  #         $scope.logged_in = true
  #       else if (status == 201 || status == 204)
  #         parameters.error_entity.message = parameters.success_message;
  #         $scope.reset_users();
  #       else
  #         if (data.error)
  #           parameters.error_entity.message = data.info;
  #           parameters.error_entity.errors = data.errors
  #         else
  #           parameters.error_entity.message = "Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
  #     )
  #     .error( (data, status) ->
  #       $scope.dataLoading -= 1
  #       if (status == 422 || status == 401)
  #         parameters.error_entity.message = data.info;
  #         parameters.error_entity.errors = data.errors
  #       else
  #         if (data.error)
  #           parameters.error_entity.message = data.info;
  #           parameters.error_entity.errors = data.errors
  #         else
  #           parameters.error_entity.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
  #     )

  $scope.resetMessages = ->
    $scope.login_error.message = null;
    $scope.login_error.errors = {};
    $scope.register_error.message = null;
    $scope.register_error.errors = {};

  $scope.reset_users = ->
    $scope.login_user.email = null;
    $scope.login_user.password = null;
    $scope.register_user.name = null;
    $scope.register_user.email = null;
    $scope.register_user.password = null;
    $scope.register_user.password_confirmation = null;
