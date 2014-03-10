@app.controller 'InviteModalController', ['$scope', '$http', '$modal', '$rootScope', ($scope, $http, $modal, $rootScope) ->
  unbind = {}
  unbind = $rootScope.$on 'openInvite', (event, data) ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_invite.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        intent: ->
          data.intent if data
      controller: 'InviteController'
    )

  $scope.$on('$destroy', unbind)
]

@app.controller 'InviteController', ['$scope', '$modalInstance', '$http', '$rootScope', 'intent', 'csAuthentication', 'csFacebook', 'csAlertService', 'csUrlService', 'csFtue', 'csDataLoading', ($scope, $modalInstance, $http, $rootScope, intent, csAuthentication, csFacebook, csAlertService, csUrlService, csFtue, csDataLoading) ->

  $scope.authentication = csAuthentication
  $scope.facebook = csFacebook
  $scope.alertService = csAlertService
  $scope.urlService = csUrlService
  $scope.dataLoadingService = csDataLoading

  $scope.waitingForGoogle = false

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
              $scope.loadFriends()
          , 300)
          trackRegistration(source, "facebook") if data.new_user
        else
          $scope.authentication.setCurrentUser(data.user)
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
        $scope.associateGoogleAccount(eventData)
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
        if $scope.inviteModalOpen
          $scope.loadGoogleContacts()
        else if $scope.formFor != "purchase" && data.new_user
          $scope.loadFriends()
      , 300)

      trackRegistration($scope.registrationSource, "google") if data.new_user

    ).error( (data, status) ->
      $scope.dataLoadingService.stop()
      if status == 503
        $scope.message = "There was a problem connecting to google"
      # $scope.message = "Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: " + JSON.stringify(data);
    )

  # This is the actual method that triggers the google authentication.
  # This builds the requests and sends it.  When the data is returned the global signInCallback method is called
  # which angular catches and turns into an event that can be watched for.
  # event:google-plus-signin-success is the event
  $scope.googleSignin = () ->
    $scope.waitingForGoogle = true
    # -# 'approvalprompt': "force" This requires them to reconfirm their permissions and gives us a new refresh token.
    gapi.auth.signIn(
      clientid: $scope.environmentConfiguration.google_app_id
      callback: 'signInCallback'
      cookiepolicy: $scope.urlService.currentSiteAsHttps()
      scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.me https://www.googleapis.com/auth/userinfo.profile'
      redirecturi: "postmessage"
      accesstype: "offline"
      # approvalprompt: "force"
    )

  # This method takes the credentials saved on the user and makes a query to google and returns the users contact information.
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

  $scope.close = ->
    $modalInstance.close()

  $scope.next = ->
    $modalInstance.close()
    if intent == 'ftue'
      csFtue.next()

  $rootScope.$on 'closeInviteFromFtue', ->
    $modalInstance.close()
]


