describe "LoginController", ->
  scope = null
  controller = null
  q = null
  timeout = null
  window = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($controller, $rootScope, _$httpBackend_, $q, $timeout, $window) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()
    # we're just declaring the httpBackend here, we're not setting up expectations or when's - they change on each test
    scope.httpBackend = _$httpBackend_
    $controller("LoginController", {$scope: scope})
    timeout = $timeout
    window = $window

    scope.alertService = jasmine.createSpyObj('csAlertService', ['addAlert', 'getAlerts'])

    deferred = $q.defer()
    promise = deferred.promise
    deferred.resolve({name: "Test User", email: "test@example.com", user_id: "123"})

    scope.facebook =
      connect: jasmine.createSpy("connect").andReturn(promise)
      friendInvites: jasmine.createSpy("friendInvites").andReturn(promise)

    inject ($injector) ->
      rootScope = $injector.get '$rootScope'
      # spyOn rootScope, '$emit'
      spyOn(rootScope, '$broadcast').andCallThrough()

    q = $q
    gapi = { auth: jasmine.createSpyObj("auth", ["signIn"]) }
    mixpanel = {
      track: jasmine.createSpy("mixpanel.track")
      people:
        increment: jasmine.createSpy("mixpanel.people.increment")
    }
    $window.gapi = gapi
    $window.mixpanel = mixpanel
    window = $window
    scope.urlService = jasmine.createSpy("urlService")
    scope.urlService.currentSiteAsHttps = jasmine.createSpy("scope.urlService.currentSiteAsHttps")
  ))

  afterEach ->
    scope.httpBackend.verifyNoOutstandingExpectation()
    scope.httpBackend.verifyNoOutstandingRequest()

  describe "#hasError", ->
    it "should return error if error isn't null", ->
      expect(scope.hasError(true)).toEqual("error")

    it "should return clean if error is null", ->
      expect(scope.hasError(null)).toEqual("clean")

  describe "#openModal", ->
    it "should open the login modal if form is 'login'", ->
      scope.openModal('login')
      expect(scope.loginModalOpen).toBe(true)

    it "should open the invite modal if form is 'incite'", ->
      scope.openModal('invite')
      expect(scope.inviteModalOpen).toBe(true)

    it "should open the welcome modal if form is 'welcome'", ->
      scope.openModal('welcome')
      expect(scope.welcomeModalOpen).toBe(true)

  describe "#closeModal", ->
    it "should close the login modal if form is 'login'", ->
      scope.closeModal('login')
      expect(scope.loginModalOpen).toBe(false)

    it "should set showForm equal to signIn when form is login", ->
      scope.showForm = "signUp"
      scope.closeModal('login')
      expect(scope.showForm).toBe("signIn")

    it "should close the invite modal if form is 'incite'", ->
      scope.closeModal('invite')
      expect(scope.inviteModalOpen).toBe(false)

    it "should close the welcome modal if form is 'welcome'", ->
      scope.closeModal('welcome')
      expect(scope.welcomeModalOpen).toBe(false)

    it "should clear the messages", ->
      scope.message = "This should be cleared"
      scope.closeModal('welcome')
      expect(scope.message).toBe(null)

  describe "#login", ->
    describe "success but not correct code", ->
      it "should be a success but not correctly", ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          "/users/sign_in.json"
          '{"user":{"email":"test@example.com","password":"apassword"}}'
        ).respond(202, {})
        scope.login()
        scope.httpBackend.flush()
        expect(scope.message).toEqual("Success, but with an unexpected success code, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: \{\}")

    describe "success", ->
      beforeEach ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          "/users/sign_in.json"
          '{"user":{"email":"test@example.com","password":"apassword"}}'
        ).respond(200, {'success': true, 'user': {'email': 'test@example.com', 'name': 'Test User'}})
        scope.login()
        scope.httpBackend.flush()

      it "should set the logged in", ->
        expect(scope.logged_in).toBe(true)

      it "should set the user on the authentication service", ->
        timeout.flush()
        expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        timeout.flush()
        expect(scope.$broadcast).toHaveBeenCalledWith('login', { user : { email : 'test@example.com', name : 'Test User'}})

      it "should create an alert message", ->
        expect(scope.alertService.addAlert).toHaveBeenCalledWith({message: 'You have been signed in.', type: 'success'})

      # it "should emit a loginSuccessful event upwards", ->
      #   expect(scope.$emit).toHaveBeenCalledWith('loginSuccessful', { user : { email : 'test@example.com', name : 'Test User'}})

    describe "error", ->
      it "should set the messages to the error", ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          "/users/sign_in.json"
          '{"user":{"email":"test@example.com","password":"apassword"}}'
        ).respond(401, {'success': false, errors: "Invalid Credentials"})
        scope.login()
        scope.httpBackend.flush()
        expect(scope.message).toBe('Invalid Credentials')

      it "should error out with a default message if it doesn't have any error response", ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          "/users/sign_in.json"
          '{"user":{"email":"test@example.com","password":"apassword"}}'
        ).respond(404, {'success': false})
        scope.login()
        scope.httpBackend.flush()
        expect(scope.message).toBe("Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: {\"success\":false}")

  describe "#register", ->
    describe "success", ->
      beforeEach ->
        scope.register_user.name = "Test User"
        scope.register_user.email = "test@example.com"
        scope.register_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          '/users.json'
          '{"user":{"name":"Test User","email":"test@example.com","password":"apassword"}}'
        ).respond(200, {'success': true, 'user': {'email': 'test@example.com', 'name': 'Test User'}})
        scope.register()
        scope.httpBackend.flush()

      it "should create an alert message", ->
        expect(scope.alertService.addAlert).toHaveBeenCalledWith({message: 'You have been registered and signed in.', type: 'success'})

      it "should set the logged in to true", ->
        expect(scope.logged_in).toEqual(true)

      it "should set the user on the authentication service", ->
        timeout.flush()
        expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        timeout.flush()
        expect(scope.$broadcast).toHaveBeenCalledWith('login', { user : { email : 'test@example.com', name : 'Test User'}})

      it "should open the invite modal if not a purchase", ->
        timeout.flush()
        expect(scope.inviteModalOpen).toBe(true)

      it "should not open the invite modal if a purchase", ->
        scope.formFor = "purchase"
        scope.register_user.name = "Test User"
        scope.register_user.email = "test@example.com"
        scope.register_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          '/users.json'
          '{"user":{"name":"Test User","email":"test@example.com","password":"apassword"}}'
        ).respond(200, {'success': true, 'user': {'email': 'test@example.com', 'name': 'Test User'}})
        scope.register()
        scope.httpBackend.flush()
        timeout.flush()
        expect(scope.inviteModalOpen).toBe(false)

      # it "should emit a loginSuccessful event upwards", ->
      #   expect(scope.$emit).toHaveBeenCalledWith('loginSuccessful', { user : { email : 'test@example.com', name : 'Test User'}})

    describe "error", ->
      describe "normal error", ->
        beforeEach ->
          scope.register_user.name = "Test User"
          scope.register_user.email = "test@example.com"
          scope.register_user.password = "apassword"
          scope.httpBackend.when(
            'POST'
            '/users.json'
            '{"user":{"name":"Test User","email":"test@example.com","password":"apassword"}}'
          ).respond(401, {errors: {name: ["Bad"]}, info: "Invalid"})
          scope.register()
          scope.httpBackend.flush()

        it "should set the error hash", ->
          expect(scope.register_error.errors).toEqual({name: ["Bad"]})

        it "should set the error message", ->
          expect(scope.message).toEqual("Invalid")

      describe "non standard error", ->
        beforeEach ->
          scope.register_user.name = "Test User"
          scope.register_user.email = "test@example.com"
          scope.register_user.password = "apassword"
          scope.httpBackend.when(
            'POST'
            '/users.json'
            '{"user":{"name":"Test User","email":"test@example.com","password":"apassword"}}'
          ).respond(404, {})
          scope.register()
          scope.httpBackend.flush()

        it "should set the error message", ->
          expect(scope.message).toBe("Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: \{\}")

  describe "#switchForm", ->
    it "should set showForm value to what is passed to it", ->
      scope.switchForm("signUp")
      expect(scope.showForm).toBe("signUp")

  # describe "#notifyLogin", ->
  #   it "should propogate an emit event up", ->
  #     scope.notifyLogin({name: "Test User"})
  #     expect(scope.$emit).toHaveBeenCalledWith('loginSuccessful', {user: {name : 'Test User'}})

  #   it "should close the modal", ->
  #     scope.notifyLogin({name: "Test User"})
  #     expect(scope.loginModalOpen).toBe(false)

  describe "#togglePassword", ->
    it "should switch the passwordType variable to text", ->
      scope.togglePassword()
      expect(scope.passwordType).toBe("text")

    it "should toggle the password type back to password when it is text", ->
      scope.passwordType = "text"
      scope.togglePassword()
      expect(scope.passwordType).toBe("password")

  describe "#reset_messages", ->
    it "should clear out the message", ->
      scope.message = "Clear me"
      scope.resetMessages()
      expect(scope.message).toBe(null)

  describe "#facebookConnect", ->
    it "should call facebook.connect()", ->
      deferred = q.defer()
      promise = deferred.promise

      scope.facebook =
        connect: jasmine.createSpy("connect").andReturn(promise)

      scope.httpBackend.expect(
        'POST'
        "/users/auth/facebook/callback.js"
        {user: {name: "Test User", email: "test@example.com", user_id: "123"}}
      ).respond(200, {user: {name: "Test User", email: "test@example.com", user_id: "123", new_user: true}})

      scope.facebookConnect()
      deferred.resolve({name: "Test User", email: "test@example.com", user_id: "123"})
      scope.httpBackend.flush()

      expect(scope.dataLoading).toBe(0)
      # expect(scope.facebook.connect().then).toHaveBeenCalled()

  describe "$on", ->
    beforeEach ->
      scope.googleConnect = jasmine.createSpy('googleConnect')

    it "should call googleConnect when data loading is greater than zero", ->
      scope.dataLoading = 1
      scope.$broadcast("event:google-plus-signin-success")
      expect(scope.googleConnect).toHaveBeenCalled()

    it "should not call googleConnect when data loading is 0", ->
      scope.dataLoading = 0
      scope.$broadcast("event:google-plus-signin-success")
      expect(scope.googleConnect).not.toHaveBeenCalled()

  describe "#googleSignin", ->
    it "should call gapi.auth.signIn", ->
      scope.googleSignin("123")
      expect(window.gapi.auth.signIn).toHaveBeenCalled()

    it "should set dataLoading +1", ->
      scope.dataLoading = 0
      scope.googleSignin("123")
      expect(scope.dataLoading).toBe(1)

  describe "#googleConnect", ->
    beforeEach ->
      scope.loadGoogleContacts = jasmine.createSpy("googleContacts")
      scope.loadFriends = jasmine.createSpy("loadFriends")

    describe "success", ->
      describe "formFor purchase", ->
        beforeEach ->
          scope.inviteModalOpen = false
          scope.formFor = "purchase"
          scope.httpBackend.expect(
            'POST'
            "/users/auth/google/callback.js"
            {google: {access_token: "12345", code: "09876", scope: "all", id_token: "45678"}}
          ).respond(200, {user: {name: "Test User", email: "test@example.com"}, new_user: true})
          scope.googleConnect({access_token: "12345", code: "09876", scope: "all", id_token: "45678"})
          scope.httpBackend.flush()

        it "should not call loadFriends", ->
          timeout.flush()
          expect(scope.loadFriends).not.toHaveBeenCalled()

        it "should not call loadGoogleContacts", ->
          timeout.flush()
          expect(scope.loadGoogleContacts).not.toHaveBeenCalled()

      describe "inviteModalOpen false", ->
        beforeEach ->
          scope.inviteModalOpen = false
          scope.httpBackend.expect(
            'POST'
            "/users/auth/google/callback.js"
            {google: {access_token: "12345", code: "09876", scope: "all", id_token: "45678"}}
          ).respond(200, {user: {name: "Test User", email: "test@example.com"}, new_user: true})
          scope.googleConnect({access_token: "12345", code: "09876", scope: "all", id_token: "45678"})
          scope.httpBackend.flush()

        it "should set dataLoading to 0", ->
          expect(scope.dataLoading).toBe(0)

        it "should set logged_in to true", ->
          expect(scope.logged_in).toBe(true)

        it "should call alertService.addAlert", ->
          expect(scope.alertService.addAlert).toHaveBeenCalledWith({message: "You have been logged in through Google.", type: 'success'})

        it "should call authentication.setCurrentUser", ->
          timeout.flush()
          expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

        it "should call loadFriends", ->
          timeout.flush()
          expect(scope.loadFriends).toHaveBeenCalled()

        it "should not call loadGoogleContacts", ->
          timeout.flush()
          expect(scope.loadGoogleContacts).not.toHaveBeenCalled()


      describe "inviteModalOpen", ->
        beforeEach ->
          scope.inviteModalOpen = true
          scope.httpBackend.expect(
            'POST'
            "/users/auth/google/callback.js"
            {google: {access_token: "12345", code: "09876", scope: "all", id_token: "45678"}}
          ).respond(200, {user: {name: "Test User", email: "test@example.com", user_id: "123", new_user: true}})
          scope.googleConnect({access_token: "12345", code: "09876", scope: "all", id_token: "45678"})
          scope.httpBackend.flush()

        it "should not call alertService.addAlert", ->
          expect(scope.alertService.addAlert).not.toHaveBeenCalled()

        it "should not call loadFriends", ->
          timeout.flush()
          expect(scope.loadFriends).not.toHaveBeenCalled()

        it "should call loadGoogleContacts", ->
          timeout.flush()
          expect(scope.loadGoogleContacts).toHaveBeenCalled()


    describe "error", ->
      beforeEach ->
        scope.httpBackend.expect(
          'POST'
          "/users/auth/google/callback.js"
          {google: {access_token: "12345", code: "09876", scope: "all", id_token: "45678"}}
        ).respond(500, {bad: "data"})

      it "should set data loading to -1", ->
        scope.dataLoading = 1
        scope.googleConnect({access_token: "12345", code: "09876", scope: "all", id_token: "45678"})
        scope.httpBackend.flush()
        expect(scope.dataLoading).toBe(0)

      # it "should set the message", ->
      #   scope.googleConnect({access_token: "12345", code: "09876", scope: "all", id_token: "45678"})
      #   scope.httpBackend.flush()
      #   expect(scope.message).toEqual("Unexplained error, potentially a server error, please report via support channels as this indicates a code defect.  Server response was: {\"bad\":\"data\"}")

  describe "#loadFriends", ->
    it "should open the invite modal", ->
      scope.loadFriends()
      expect(scope.inviteModalOpen).toBe(true)

  describe "#loadGoogleContacts", ->
    beforeEach ->
      scope.switchModal = jasmine.createSpy("switchModal")
      scope.httpBackend.expect(
        'GET'
        "/users/contacts/google.js"
      ).respond(200, [{name: "Dan Ahern", email: "danahern@chefsteps.com"}, {name: "Test Guy", email: "test@chefsteps.com"}])
      scope.loadGoogleContacts()
      scope.httpBackend.flush()

    it "should set dataLoading to 0", ->
      expect(scope.dataLoading).toBe(0)

    it "should set inviteFriends to mapped data", ->
      expect(scope.inviteFriends).toEqual([{name: "Dan Ahern", email: "danahern@chefsteps.com", value: false}, {name: "Test Guy", email: "test@chefsteps.com", value: false}])

    it "should call switchModal", ->
      expect(scope.switchModal).toHaveBeenCalledWith('invite', 'googleInvite')

  describe "#sendInvitation", ->
    beforeEach ->
      scope.inviteFriends = [{email: "danahern@chefsteps.com", name: "Dan Ahern", value: true}, {email: "test@chefsteps.com", name: "Test User", value: true}, {email: "nogood@example.com", name: "No Good", value: false}]
      scope.switchModal = jasmine.createSpy("switchModal")
      scope.httpBackend.expect(
        'POST'
        "/users/contacts/invite.js"
        {emails: ["danahern@chefsteps.com", "test@chefsteps.com"]}
      ).respond(200, {})
      scope.sendInvitation()
      scope.httpBackend.flush()

    it "should call mixpanel track", ->
      expect(window.mixpanel.track).toHaveBeenCalledWith("Google Invites Sent")

    it "should call mixpanel people increment", ->
      expect(window.mixpanel.people.increment).toHaveBeenCalledWith("Google Invitations", 2)

    it "should set dataLoading -1", ->
      expect(scope.dataLoading).toBe(0)

    it "should call switchModal", ->
      expect(scope.switchModal).toHaveBeenCalledWith("googleInvite", "welcome")


  describe "#sendInvites", ->
    it "should call the facebook.friendInvites method", ->
      scope.sendInvites()
      expect(scope.facebook.friendInvites).toHaveBeenCalled()

    it "should call mixpanel track", ->
      scope.sendInvites()
      scope.$apply()
      expect(window.mixpanel.track).toHaveBeenCalledWith("Facebook Invites Sent")

    it "should set invitationsNextText to Next", ->
      scope.sendInvites()
      expect(scope.invitationsNextText).toEqual("Next")

  describe "#welcome", ->
    it "should close the invite modal", ->
      scope.welcome()
      expect(scope.inviteModalOpen).toBe(false)

    it "should open the welcome modal", ->
      scope.welcome()
      timeout.flush()
      expect(scope.welcomeModalOpen).toBe(true)

  describe "#switchModal", ->
    beforeEach ->
      scope.closeModal = jasmine.createSpy("closeModal")
      scope.openModal = jasmine.createSpy("openModal")
      scope.switchModal('invite', 'welcome')
      timeout.flush()

    it "should set call closeModal", ->
      expect(scope.closeModal).toHaveBeenCalledWith("invite")

    it "should set call openModal", ->
      expect(scope.openModal).toHaveBeenCalledWith("welcome")

  describe "#friendsSelected", ->
    it "should return only selected values", ->
      scope.inviteFriends = [{email: "danahern@chefsteps.com", name: "Dan Ahern", value: true}, {email: "test@chefsteps.com", name: "Test User", value: true}, {email: "nogood@example.com", name: "No Good", value: false}]
      expect(scope.friendsSelected()).toEqual([{email: "danahern@chefsteps.com", name: "Dan Ahern", value: true}, {email: "test@chefsteps.com", name: "Test User", value: true}])

  describe "#validNameAndEmail", ->
    it "should return false if values aren't set", ->
      scope.register_user.email = null
      scope.register_user.name = null
      expect(scope.validNameAndEmail()).toBe false

    it "should return true if the values are set", ->
      scope.register_user.email = "a@b.c"
      scope.register_user.name = "Test"
      expect(scope.validNameAndEmail()).toBe true
