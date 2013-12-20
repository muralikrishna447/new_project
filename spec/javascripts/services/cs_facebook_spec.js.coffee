describe 'csFacebook', ->
  facebook = null
  scope = null
  fb = null
  window = null
  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach ->
    module('ChefStepsApp')
    inject ($rootScope, csFacebook, $q, $window) ->
      scope = $rootScope.$new()
      facebook = csFacebook
      q = $q
      window = $window
      window.FB =
        login: jasmine.createSpy("login").andReturn({
          name: "Test User"
          email: "test@example.com"
          access_token: "321"
          user_id: "123"
          provider: "facebook"
        }).andCallFake( ->
          response = {authResponse: {accessToken: '321', userID: '123'}}
          if response.authResponse
            user = {
              name: null
              email: null
              access_token: null
              user_id: null
              provider: "facebook"
            }

            user.access_token = response.authResponse.accessToken
            user.user_id = response.authResponse.userID

            FB.api('/me', (profileResponse) ->
              $rootScope.$apply ->
                user.name = profileResponse.name
                user.email = profileResponse.email
                deferred.resolve(user)
            )
        )
        api: jasmine.createSpy("api").andReturn({name: "Test User", email: "test@example.com"})
        ui: jasmine.createSpy("ui")
      # window.FB.login = spyOn(window.FB, 'login').andReturn({authResponse: {accessToken: "123", user_id: "321"}}, "connected")
      fb = window.FB

  # now run that scope through the controller function,
  # injecting any services or other injectables we need.
  it "should initialize", ->
    expect(facebook).toNotBe(null)

  describe "#connect", ->
    it "should call FB.login", ->
      facebook.connect()
      expect(fb.login).toHaveBeenCalled()

    it "should return a promise", ->
      expect(facebook.connect().then).toBeDefined()

    it "should call FB.api and get my profile", ->
      facebook.connect()
      expect(fb.api).toHaveBeenCalledWith('/me', jasmine.any(Function))

    it "should return user", ->
      user = { name: "Test User", email: "test@example.com", access_token: "321", user_id: "123", provider: "facebook" }
      facebook.connect().then( (response) ->
        expect(response).toEqual(user)
      )

  describe "#friendInvites", ->
    it "should call the FB.ui", ->
      facebook.friendInvites()
      expect(fb.ui).toHaveBeenCalled()

    it "should return a promise", ->
      expect(facebook.friendInvites().then).toBeDefined()
