angular.module('ChefStepsApp').controller 'LoginController', ["$scope", "$rootScope", "$http", "csAuthentication", "csFacebook", "csAlertService", "$q", "$timeout", "csUrlService", "csIntent", "csFtue", "$route", "$modal", "csDataLoading", "csAdwords", "csFacebookConversion", ($scope, $rootScope, $http, csAuthentication, csFacebook, csAlertService, $q, $timeout, csUrlService, csIntent, csFtue, $route, $modal, csDataLoading, csAdwords, csFacebookConversion) ->
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

  $scope.modalOptions = {dialogFade:true, backdrop: 'static', dialogClass: "modal login-controller-modal"}

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

  trackRegistration = (source, method) ->
    properties = {source : source, method: method}
    mixpanel.track('Signed Up JS', _.extend(properties, $rootScope.splits))
    _gaq.push(['_trackEvent', 'Sign Up', 'Complete', null, null, true]);

  $scope.setIntent = (intent) ->
    $scope.intent = intent

  $scope.registrationSource = null

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
    else if form == "kioskWelcome"
      $scope.kioskWelcomeModalOpen = true
    $scope.dataLoadingService.setFullScreen(true)


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
    $scope.dataLoadingService.setFullScreen(false)

  $scope.togglePassword = ->
    if $scope.passwordType == "password"
      $scope.passwordType = "text"
    else
      $scope.passwordType = "password"

  $scope.login = ->
    $scope.dataLoadingService.setFullScreen(true)
    $scope.dataLoadingService.start()
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
        $scope.dataLoadingService.stop()
        $scope.dataLoadingService.setFullScreen(false)
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

  $scope.register = (source = "unknown") ->
    unless $scope.validNameAndEmail() && $scope.register_user.password
      $scope.register_error.errors.name = ["Please provide a name"] unless !!$scope.register_user.name
      $scope.register_error.errors.email = ["Please enter a valid email address"] unless /.*@.*\..*/.test($scope.register_user.email)
      $scope.register_error.errors.password = ["Please enter a password"] unless !!$scope.register_user.password
      return
    $scope.dataLoadingService.setFullScreen(true)
    $scope.dataLoadingService.start()
    $scope.resetMessages()
    $http(
      method: 'POST'
      url: "/users.json"
      data:
        user:
          name: $scope.register_user.name
          email: $scope.register_user.email
          password: $scope.register_user.password
      ).success( (data, status) ->
        if (status == 200)
          $scope.dataLoadingService.stop()
          if source == 'kiosk'
            $scope.openModal('kioskWelcome')
            $timeout( ->
              window.location.reload()
            ,5000)
          else
            trackRegistration(source, "standard")
            # Adwords tracking see http://stackoverflow.com/questions/2082129/how-to-track-a-google-adwords-conversion-onclick
            csAdwords.track(998032928,'77TfCIjjrAgQoIzz2wM')
            csFacebookConversion.track(6014798030226,0.00)
            $scope.logged_in = true
            $scope.closeModal('login', false)
            $scope.alertService.addAlert({message: "You have been registered and signed in.", type: "success"})
            $timeout( -> # Done so that the modal has time to close before triggering events
              $scope.$apply()
              $scope.authentication.setCurrentUser(data.user)
              unless $scope.formFor == "purchase"
                if $scope.intent == 'ftue'
                  csIntent.setIntent('ftue')
                  csFtue.start()
            , 300)
      ).error( (data, status) ->
        $scope.dataLoadingService.stop()
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

  # This is the call that gets the facebook credientials and then passes them into our rails server,
  # which then creates the user or logs them in.
  $scope.facebookConnect = (source="undefined") ->
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
        unless source == "socialConnect"
          $scope.alertService.addAlert({message: "You have been logged in through Facebook.", type: "success"})
          $timeout( -> # Done so that the modal has time to close before triggering events
            $scope.dataLoadingService.stop()
            $scope.authentication.setCurrentUser(data.user)
            if $scope.formFor != "purchase" && data.new_user
              csIntent.setIntent('ftue')
              csFtue.start()
          , 300)
          trackRegistration(source, "facebook") if data.new_user
        else
          $scope.authentication.setCurrentUser(data.user)
          $scope.$broadcast('socialConnect', {})
      ).error( (data, status) ->
        $scope.dataLoadingService.stop()
        $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
      )
    )

  # Because google is a little different we need to watch for an event
  # This is the event that gets fired when google successfully returns the google credientials
  $scope.$on "event:google-plus-signin-success", (event, eventData) ->
    if $scope.waitingForGoogle
      $scope.dataLoadingService.start()
      $scope.$apply( ->
        $scope.googleConnect(eventData)
      )

  # This is the actual method that triggers the google authentication.
  # This builds the requests and sends it.  When the data is returned the global signInCallback method is called
  # which angular catches and turns into an event that can be watched for.
  # event:google-plus-signin-success is the event
  $scope.googleSignin = ->
    $scope.waitingForGoogle = true
    # -# 'approvalprompt': "force" This requires them to reconfirm their permissions and gives us a new refresh token.
    gapi.auth.signIn(
      callback: 'signInCallback'
      clientid: $scope.environmentConfiguration.google_app_id
      cookiepolicy: $scope.urlService.currentSiteAsHttps()
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile'
      redirecturi: "postmessage"
      accesstype: "offline"
      # approvalprompt: "force"
    )

  # This methods sends the data to the rails server after the creditials are returned from google.
  # It will login or create a user.
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
        $scope.$broadcast('socialConnect', {})
        if $scope.inviteModalOpen
          $scope.loadGoogleContacts()
        else if $scope.formFor != "purchase" && data.new_user
          csIntent.setIntent('ftue')
          csFtue.start()
      , 300)

      trackRegistration($scope.registrationSource, "google") if data.new_user

    ).error( (data, status) ->
      $scope.dataLoadingService.stop()
      if status == 503
        $scope.message = "There was a problem connecting to google"
      # $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
    )

  # This method takes the credentials saved on the user and makes a query to google and returns the users contact information.
  $scope.loadGoogleContacts = ->
    $scope.dataLoadingService.start()
    $http(
      method: "GET"
      url: "/users/contacts/google.js"
    ).success( (data, status) ->
      friends = _.map(data, (contact) -> {name: contact.name, email: contact.email, value: false})
      $scope.inviteFriends = friends
      $scope.dataLoadingService.stop()
      $scope.switchModal('invite', 'googleInvite')

    )


  # This is the method that opens up the facebook module for sending messages to your friends.
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

  # This method sends google invitations to the selected friends.
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
    $scope.dataLoadingService.setFullScreen(true)
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

  $scope.closeNewModal = ->
    $scope.dataLoadingService.setFullScreen(false)
    $close()

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
    $scope.dataLoadingService.start()
    $http(
      method: 'DELETE'
      url: "/users/social/disconnect.json"
      params:
        service: service
      )
      .success( (data, status) ->
        $scope.dataLoadingService.stop()
        $scope.authentication.setCurrentUser(data.user)
      )
      .error( (data, status) ->
        $scope.dataLoadingService.stop()

      )

  $scope.$on 'openLoginModal', ->
    $scope.openModal('login')

  $scope.kioskReload = ->
    window.location.reload()
]