describe "LoginController", ->
  scope = null
  controller = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($controller, $rootScope, _$httpBackend_) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()
    # we're just declaring the httpBackend here, we're not setting up expectations or when's - they change on each test
    scope.httpBackend = _$httpBackend_
    $controller("LoginController", {$scope: scope})

    inject ($injector) ->
      rootScope = $injector.get '$rootScope'
      # spyOn rootScope, '$emit'
      spyOn rootScope, '$broadcast'
  ))

  afterEach ->
    scope.httpBackend.verifyNoOutstandingExpectation()
    scope.httpBackend.verifyNoOutstandingRequest()

  describe "#login", ->
    describe "success but not correct code", ->
      it "should be a success but not correctly", ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          '/users/sign_in.json'
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
          '/users/sign_in.json'
          '{"user":{"email":"test@example.com","password":"apassword"}}'
        ).respond(200, {'success': true, 'user': {'email': 'test@example.com', 'name': 'Test User'}})
        scope.login()
        scope.httpBackend.flush()

      it "should set the scope message on success", ->
        expect(scope.message).toBe('You have been signed in.')

      it "should set the logged in", ->
        expect(scope.logged_in).toBe(true)

      it "should set the user on the authentication service", ->
        expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        expect(scope.$broadcast).toHaveBeenCalledWith('login', { user : { email : 'test@example.com', name : 'Test User'}})

      # it "should emit a loginSuccessful event upwards", ->
      #   expect(scope.$emit).toHaveBeenCalledWith('loginSuccessful', { user : { email : 'test@example.com', name : 'Test User'}})

    describe "error", ->
      it "should set the messages to the error", ->
        scope.login_user.email = "test@example.com"
        scope.login_user.password = "apassword"
        scope.httpBackend.when(
          'POST'
          '/users/sign_in.json'
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
          '/users/sign_in.json'
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

      it "should set the success message", ->
        expect(scope.message).toBe("You have been registered and logged in.")

      it "should set the logged in to true", ->
        expect(scope.logged_in).toEqual(true)

      it "should set the user on the authentication service", ->
        expect(scope.authentication.currentUser()).toEqual({'email': 'test@example.com', 'name': 'Test User'})

      it "should close the modal", ->
        expect(scope.loginModalOpen).toBe(false)

      it "should broadcast a login event globally", ->
        expect(scope.$broadcast).toHaveBeenCalledWith('login', { user : { email : 'test@example.com', name : 'Test User'}})

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