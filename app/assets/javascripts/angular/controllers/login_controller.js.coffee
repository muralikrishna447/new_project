angular.module('ChefStepsApp').controller 'LoginController', ["$scope", "$http", "csAuthentication", "csFacebook", "csAlertService", "$q", "$timeout", "csUrlService", "$modal", "csDataLoading", ($scope, $http, csAuthentication, csFacebook, csAlertService, $q, $timeout, csUrlService, $modal, csDataLoading) ->
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
  $scope.dataLoadingService = csDataLoading

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static', dialogClass: "modal login-controller-modal"}

  $scope.loginModalOpen = false
  $scope.inviteModalOpen = false
  $scope.googleInviteModalOpen = false
  $scope.welcomeModalOpen = false

  $scope.passwordType = "password" # Defaults password to the password input type, but lets it switch to just text

  $scope.formFor = "signIn" # [signIn, purchase] # This determines if it's being used for a purchase or if it's being used for signup/signin
  $scope.invitationsNextText = "Skip"

  $scope.inviteFriends = []

  $scope.headerText = null

  $scope.showMadlibPassword = false
  $scope.googleLoaded = false
  $scope.validEmailSent = false
  $scope.waitingForGoogle = false

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
    else if form == "googleInvite"
      $scope.googleInviteModalOpen = true
    else if form == "welcome"
      $scope.welcomeModalOpen = true
    $scope.dataLoadingService.willBeFullScreen(true)

  $scope.closeModal = (form, abandon=true) ->
    $scope.resetMessages()
    $scope.reset_users()
    if abandon
      mixpanel.track('Modal Abandoned')
      mixpanel.people.set('Login Modal Abandoned')
    if form == "login"
      $scope.showForm = "signIn"
      $scope.loginModalOpen = false
    else if form == "invite"
      $scope.inviteModalOpen = false
    else if form == "googleInvite"
      $scope.googleInviteModalOpen = false
    else if form == "welcome"
      $scope.welcomeModalOpen = false
    $scope.dataLoadingService.willBeFullScreen(false)


  $scope.togglePassword = ->
    if $scope.passwordType == "password"
      $scope.passwordType = "text"
    else
      $scope.passwordType = "password"

  $scope.login = ->
    $scope.dataLoading += 1
    $scope.resetMessages()
    $scope.fakeLogin()
    $http(
      method: 'POST'
      url: "/users/sign_in.json"
      data:
        user:
          email: $scope.login_user.email
          password: $scope.login_user.password
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          $scope.logged_in = true
          $scope.closeModal('login', false)
          $scope.alertService.addAlert({message: "You have been signed in.", type: "success"})
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.setCurrentUser(data.user)
          , 300)

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
          $scope.closeModal('login', false)
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.authentication.clearCurrentUser()
          , 300)
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
    unless $scope.validNameAndEmail() && $scope.register_user.password
      $scope.register_error.errors.name = ["Please provide a name"] unless !!$scope.register_user.name
      $scope.register_error.errors.email = ["Please enter a valid email address"] unless /.*@.*\..*/.test($scope.register_user.email)
      $scope.register_error.errors.password = ["Please enter a password"] unless !!$scope.register_user.password
      return
    $scope.dataLoading += 1
    $scope.resetMessages()
    $http(
      method: 'POST'
      url: "/users.json"
      data:
        user:
          name: $scope.register_user.name
          email: $scope.register_user.email
          password: $scope.register_user.password
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 200)
          _gaq.push(['_trackEvent', 'Sign Up', 'Complete', null, null, true]);
          $scope.logged_in = true
          $scope.closeModal('login', false)
          $scope.alertService.addAlert({message: "You have been registered and signed in.", type: "success"})
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.$apply()
            $scope.authentication.setCurrentUser(data.user)
            unless $scope.formFor == "purchase"
              $scope.loadFriends()
          , 300)
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

  $scope.facebookConnect = (forLogin=true) ->
    $scope.facebook.connect().then( (user) ->
      $scope.dataLoadingService.start()
      $http(
        method: "POST"
        url: "/users/auth/facebook/callback.js"
        data:
          user: user
      ).success( (data, status) ->
        $scope.logged_in = true
        $scope.closeModal('login', false)
        if forLogin
          $scope.alertService.addAlert({message: "You have been logged in through Facebook.", type: "success"})
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.dataLoadingService.stop()
            $scope.authentication.setCurrentUser(data.user)
            if $scope.formFor != "purchase" && data.new_user
              $scope.loadFriends()
          , 300)
        else
          $scope.authentication.setCurrentUser(data.user)
      ).error( (data, status) ->
        $scope.dataLoadingService.stop()
        $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )
    )

  # Because google is a little different we need to watch for an event
  $scope.$on "event:google-plus-signin-success", (event, eventData) ->
    # if $scope.dataLoading > 0
    if $scope.waitingForGoogle
      $scope.dataLoadingService.start()
      $scope.$apply( ->
        $scope.googleConnect(eventData)
      )

  $scope.googleSignin = (google_app_id) ->
    # $scope.dataLoading += 1
    $scope.waitingForGoogle = true
    # -# 'approvalprompt': "force" This requires them to reconfirm their permissions and gives us a new refresh token.
    gapi.auth.signIn(
      callback: 'signInCallback'
      clientid: google_app_id
      cookiepolicy: $scope.urlService.currentSiteAsHttps()
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile'
      redirecturi: "postmessage"
      accesstype: "offline"
      # approvalprompt: "force"
    )

  $scope.googleConnect = (eventData) ->
    $http(
      method: "POST"
      url: "/users/auth/google/callback.js"
      data:
        google: eventData
    ).success( (data, status) ->
      unless $scope.inviteModalOpen
        $scope.logged_in = true
        $scope.closeModal('login', false)
        $scope.alertService.addAlert({message: "You have been logged in through Google.", type: "success"})
      $timeout( -> # Done so that the modal has time to close before triggering events
        $scope.dataLoadingService.stop()
        $scope.authentication.setCurrentUser(data.user)
        if $scope.inviteModalOpen
          $scope.loadGoogleContacts()
        else if $scope.formFor != "purchase" && data.new_user
          $scope.loadFriends()
      , 300)
    ).error( (data, status) ->
      $scope.dataLoadingService.stop()
      if status == 503
        $scope.message = "There was a problem connecting to google"
      # $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
    )

  $scope.loadFriends = ->
    $scope.openModal('invite')
    # This version uses the chefsteps styling
    # $scope.facebook.friends().then( (friends) ->
    #   $scope.inviteFriends = friends
    # )

  $scope.loadGoogleContacts = ->
    $scope.dataLoading += 1
    $http(
      method: "GET"
      url: "/users/contacts/google.js"
    ).success( (data, status) ->
      friends = _.map(data, (contact) -> {name: contact.name, email: contact.email, value: false})
      $scope.inviteFriends = friends
      $scope.dataLoading -= 1
      $scope.switchModal('invite', 'googleInvite')

    )

  $scope.sendInvitation = ->
    $scope.dataLoading += 1
    friends = $scope.friendsSelected()
    friendEmails = _.pluck(friends, 'email')
    $http(
      method: "POST"
      url: "/users/contacts/invite.js"
      data:
        emails: friendEmails
    ).success( (data, status) ->
      mixpanel.track("Google Invites Sent")
      mixpanel.people.increment("Google Invitations", friendEmails.length)
      $scope.dataLoading -= 1
      $scope.switchModal('googleInvite', 'welcome')
    )


  $scope.sendInvites = ->
    $scope.invitationsNextText = "Next"
    $scope.facebook.friendInvites($scope.authentication.currentUser().id).then( ->
      mixpanel.track("Facebook Invites Sent")
      mixpanel.people.increment('Facebook Invites Sent')
    )
    #This is a promise so you can do promisey stuff with it.
    # This version uses the chefsteps styling
    # friends = _.filter($scope.inviteFriends, (friend) -> (friend.value == true))
    # friendIDs = _.pluck(friends, 'id')
    # $scope.facebook.friendInvites(friendIDs).then( ->
    #   $scope.closeModal("invite")
    # )

  $scope.welcome = ->
    $scope.switchModal('invite', 'welcome')

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

  $scope.switchModal = (from, to) ->
    $scope.closeModal(from, false)
    $timeout( -> # Done so that the modal has time to close before triggering events
      $scope.openModal(to)
    , 300)

  $scope.friendsSelected = ->
    _.filter($scope.inviteFriends, (friend) -> (friend.value == true))

  $scope.validNameAndEmail = ->
    valid_name = !!$scope.register_user.name
    valid_email = /.*@.*\..*/.test($scope.register_user.email)
    validation = valid_name && valid_email
    if validation
      $scope.showMadlibPassword = true
    validation

  $scope.socialConnect = ->
    $scope.dataLoadingService.willBeFullScreen(true)
    modalInstance = $modal.open(
      templateUrl: "socialConnect.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve:
        authentication: -> $scope.authentication
      controller: ($scope, $modalInstance, authentication) ->
        $scope.authentication = authentication
    )

  $scope.freeTrialRegister = ->
    $scope.dataLoading += 1
    $scope.resetMessages()
    $http(
      method: 'POST'
      url: "/users.json"
      data:
        user:
          free_trial: true
          email: $scope.register_user.email
          password: $scope.register_user.password
      )
      .success( (data, status) ->
        if (status == 200)
          $scope.logged_in = true
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.$apply()
            $scope.authentication.setCurrentUser(data.user)
            $scope.dataLoading -= 1
            unless $scope.formFor == "purchase"
              $scope.loadFriends()
          , 300)
          # $scope.notifyLogin(data.user)
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1
        if (status == 401)
          $scope.message = data.info;
          $scope.register_error.errors = data.errors
          $scope.register_error.errors.password = ["Please enter a password"] if !$scope.register_user.password
          $scope.register_error.errors.email = ["Please enter a valid email"] unless /.*@.*\..*/.test($scope.register_user.email)
          $scope.showForm = "signUp"
          $scope.openModal("login")
        else
          $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )

  $scope.startedDataFill = ->
    unless $scope.showMadlibPassword
      $scope.showMadlibPassword = true
      mixpanel.track("Free Trial Data Entered")
    if /.*@.*\..*/.test($scope.register_user.email) && !$scope.validEmailSent
      mixpanel.track("Free Trial Valid Email Filled")
      $scope.validEmailSent = true

  # This submits a fake login request to a hidden iframe.  It's to do the remember me stuff in the browser
  $scope.fakeLogin = ->
    $("#fakelogin #email").val($scope.login_user.email)
    $("#fakelogin #password").val($scope.login_user.password)
    $("#fakelogin").submit()


  $scope.disconnectSocial = (service) ->
    $scope.dataLoading += 1
    console.log("disconnectSocial")
    $http(
      method: 'DELETE'
      url: "/users/social/disconnect.json"
      params:
        service: service
      )
      .success( (data, status) ->
        $scope.dataLoading -= 1
        $scope.authentication.setCurrentUser(data.user)
      )
      .error( (data, status) ->
        $scope.dataLoading -= 1

      )


]