describe 'csAuthentication', ->
  authentication = null
  rootScope = null
  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach ->
    module('ChefStepsApp')
    inject ($injector) ->
      rootScope = $injector.get '$rootScope'
      spyOn rootScope, '$broadcast'

    inject (csAuthentication) ->
      authentication = csAuthentication

  # now run that scope through the controller function,
  # injecting any services or other injectables we need.
  it "should initialize", ->
    expect(authentication).toNotBe(null)

  describe "current_user", ->
    it "should return null if no user is set", ->
      expect(authentication.currentUser()).toBe(null)

    it "should return the current_user if one is set", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.currentUser()).toEqual({email: "danahern@chefsteps.com"})

  describe "set_current_user", ->
    it "should set the value of the user", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.currentUser()).toEqual({email: "danahern@chefsteps.com"})

    it "should broadcast a login event globally", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(rootScope.$broadcast).toHaveBeenCalledWith('login', {user: {email: "danahern@chefsteps.com"}});

  describe "logged_in", ->
    it "should return true if user exists", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.loggedIn()).toBe(true)

    it "should return false if the user is blank", ->
      expect(authentication.loggedIn()).toBe(false)