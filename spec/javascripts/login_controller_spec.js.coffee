describe "LoginController", ->
  scope = null
  controller = null
  q = null
  window = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($controller, $rootScope, _$httpBackend_, $q, $window) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()
    # we're just declaring the httpBackend here, we're not setting up expectations or when's - they change on each test
    scope.httpBackend = _$httpBackend_
    $controller("LoginController", {$scope: scope})
    window = $window

    scope.alertService = jasmine.createSpyObj('csAlertService', ['addAlert', 'getAlerts'])

    scope.facebook =
      connect: ( ->
        then: jasmine.createSpy("connect").andReturn({name: "Test User", email: "test@example.com", user_id: "123"})
      )
      friendInvites: jasmine.createSpy("friendInvites")

    inject ($injector) ->
      rootScope = $injector.get '$rootScope'
      # spyOn rootScope, '$emit'
      spyOn rootScope, '$broadcast'

    q = $q
    scope.urlService = jasmine.createSpy("urlService")
    scope.urlService.currentSiteAsHttps = jasmine.createSpy("scope.urlService.currentSiteAsHttps").andReturn("")
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
        waits(100)
        runs ->
          expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        waits(100)
        runs ->
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
        waits(100)
        runs ->
          expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        waits(100)
        runs ->
          expect(scope.$broadcast).toHaveBeenCalledWith('login', { user : { email : 'test@example.com', name : 'Test User'}})

      it "should open the invite modal if not a purchase", ->
        waits(100)
        runs ->
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
        waits(100)
        runs ->
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
        # scope.httpBackend.expect(
        #   'POST'
        #   "/users/auth/facebook/callback.js"
        #   {user: {name: "Test User", email: "test@example.com", user_id: "123"}}
        # ).respond(200, {user: {name: "Test User", email: "test@example.com", user_id: "123", new_user: true}})
        # defer = q.defer()
        # scope.facebookConnect()
        # defer.resolve()
        # expect(scope.facebook.connect().then).toHaveBeenCalled()

    describe "#loadFriends", ->
      it "should open the invite modal", ->
        scope.loadFriends()
        expect(scope.inviteModalOpen).toBe(true)


    describe "#sendInvites", ->
      it "should call the facebook.friendInvites method", ->
        scope.sendInvites()
        expect(scope.facebook.friendInvites).toHaveBeenCalled()

    describe "#welcome", ->
      it "should close the invite modal", ->
        scope.welcome()
        expect(scope.inviteModalOpen).toBe(false)

      it "should open the welcome modal", ->
        scope.welcome()
        waits(100)
        runs ->
          expect(scope.welcomeModalOpen).toBe(true)

    describe "#validNameAndEmail", ->
      it "should return false if values aren't set", ->
        scope.register_user.email = null
        scope.register_user.name = null
        expect(scope.validNameAndEmail()).toBe false

      it "should return true if the values are set", ->
        scope.register_user.email = "a@b.c"
        scope.register_user.name = "Test"
        expect(scope.validNameAndEmail()).toBe true
