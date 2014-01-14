angular.module('ChefStepsApp').controller 'LoginController', ["$scope", "$http", "csAuthentication", "csFacebook", "csAlertService", "csUrlService", ($scope, $http, csAuthentication, csFacebook, csAlertService, csUrlService) ->
  $scope.dataLoading = 0
  $scope.login_user = {email: null, password: null};
  $scope.login_error = {message: null, errors: {}};
  $scope.register_user = {email: null, password: null, password_confirmation: null};
  $scope.register_error = {message: null, errors: {}};

  $scope.showForm = "signIn" # For switching between signUp and signIn.

  $scope.authentication = csAuthentication # Authentication service
  $scope.facebook = csFacebook # Facebook service
  $scope.alertService = csAlertService
  $scope.urlService = csUrlService

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static', dialogClass: "modal login-controller-modal"}

  $scope.loginModalOpen = false
  $scope.inviteModalOpen = false
  $scope.welcomeModalOpen = false

  $scope.passwordType = "password" # Defaults password to the password input type, but lets it switch to just text

  $scope.formFor = "signIn" # [signIn, purchase] # This determines if it's being used for a purchase or if it's being used for signup/signin
  $scope.invitationsNextText = "Skip"

  $scope.inviteFriends = []

  $scope.hasError = (error) ->
    if error
      "error"
    else
      "clean"

  $scope.switchForm = (form) ->
    $scope.showForm = form

  $scope.openModal = (form) ->
    if form == "login"
      $scope.loginModalOpen = true
    else if form == "invite"
      $scope.inviteModalOpen = true
    else if form == "welcome"
      $scope.welcomeModalOpen = true

  $scope.closeModal = (form) ->
    $scope.resetMessages()
    $scope.reset_users()
    if form == "login"
      $scope.loginModalOpen = false
    else if form == "invite"
      $scope.inviteModalOpen = false
    else if form == "welcome"
      $scope.welcomeModalOpen = false


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
      url: "#{$scope.urlService.currentSiteAsHttps()}/users/sign_in.json"
      data:
        user:
          email: $scope.login_user.email
          password: $scope.login_user.password
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.logged_in = true
          $scope.closeModal('login')
          $scope.alertService.addAlert({message: "You have been signed in.", type: "success"})
          setTimeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.setCurrentUser(data.user)
          , 100)

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
      url: "/users/sign_out.json"
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.message = "You have been signed out."
          $scope.logged_in = false
          $scope.closeModal('login')
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

  # Not ready yet.
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
      url: "#{$scope.urlService.currentSiteAsHttps()}/users.json"
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
          $scope.closeModal('login')
          $scope.alertService.addAlert({message: "You have been registered and signed in.", type: "success"})
          setTimeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.setCurrentUser(data.user)
            unless $scope.formFor == "purchase"
              $scope.loadFriends()
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

  # Not ready yet.
  # $scope.change_password = ->
  #   $scope.submit(
  #     method: 'PUT'
  #     url: '/users/password.json'
  #     data: {user: {email: $scope.register_user.email
  #       password: $scope.register_user.password
  #       password_confirmation: $scope.register_user.password_confirmation}}
  #     success_message: "Your password has been updated."
  #     error_entity: $scope.register_error)

  # Not ready yet.
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

  $scope.facebookConnect = ->
    $scope.dataLoading += 1
    $scope.facebook.connect().then( (user) ->
      $http(
        method: "POST"
        url: "/users/auth/facebook/callback.js"
        data:
          user: user
      ).success( (data, status) ->
        $scope.dataLoading -= 1
        $scope.logged_in = true
        $scope.closeModal('login')
        $scope.alertService.addAlert({message: "You have been logged in through Facebook.", type: "success"})
        setTimeout( -> # Done so that the modal has time to close before triggering events
          $scope.authentication.setCurrentUser(data.user)
          if $scope.formFor != "purchase" && data.new_user
            $scope.loadFriends()
        , 100)
      ).error( (data, status) ->
        $scope.dataLoading -= 1
        $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )
    )

  $scope.loadFriends = ->
    $scope.openModal('invite')
    # This version uses the chefsteps styling
    # $scope.facebook.friends().then( (friends) ->
    #   $scope.inviteFriends = friends
    # )

  $scope.sendInvites = ->
    $scope.invitationsNextText = "Next"
    $scope.facebook.friendInvites()
    #This is a promise so you can do promisey stuff with it.
    # This version uses the chefsteps styling
    # friends = _.filter($scope.inviteFriends, (friend) -> (friend.value == true))
    # friendIDs = _.pluck(friends, 'id')
    # $scope.facebook.friendInvites(friendIDs).then( ->
    #   $scope.closeModal("invite")
    # )

  $scope.welcome = ->
    $scope.closeModal('invite')
    setTimeout( -> # Done so that the modal has time to close before triggering events
      $scope.openModal('welcome')
    , 100)

  $scope.resetMessages = ->
    $scope.message = null
    $scope.login_error.message = null
    $scope.login_error.errors = {}
    $scope.register_error.message = null
    $scope.register_error.errors = {}

  $scope.reset_users = ->
    $scope.login_user.email = null
    $scope.login_user.password = null
    $scope.register_user.name = null
    $scope.register_user.email = null
    $scope.register_user.password = null
    $scope.register_user.password_confirmation = null


]