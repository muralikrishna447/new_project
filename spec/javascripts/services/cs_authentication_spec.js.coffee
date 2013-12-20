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

  describe "#current_user", ->
    it "should return null if no user is set", ->
      authentication.clearCurrentUser()
      expect(authentication.currentUser()).toBe(null)

    it "should return the current_user if one is set", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.currentUser()).toEqual({email: "danahern@chefsteps.com"})

  describe "#set_current_user", ->
    it "should set the value of the user", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.currentUser()).toEqual({email: "danahern@chefsteps.com"})

    it "should broadcast a login event globally", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(rootScope.$broadcast).toHaveBeenCalledWith('login', {user: {email: "danahern@chefsteps.com"}})

    describe "#clearCurrentUser", ->
    it "should clear the value of the user", ->
      authentication.clearCurrentUser()
      expect(authentication.currentUser()).toEqual(null)

    it "should broadcast a logout event globally", ->
      authentication.clearCurrentUser()
      expect(rootScope.$broadcast).toHaveBeenCalledWith('logout')

  describe "#logged_in", ->
    it "should return true if user exists", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com"})
      expect(authentication.loggedIn()).toBe(true)

    it "should return false if the user is blank", ->
      authentication.clearCurrentUser()
      expect(authentication.loggedIn()).toBe(false)

  describe "#isAdmin", ->
    it "should return true if user is an admin", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com", role: "admin"})
      expect(authentication.isAdmin()).toBe(true)

    it "should return false if user is not an admin", ->
      authentication.setCurrentUser({email: "danahern@chefsteps.com", role: ""})
      expect(authentication.isAdmin()).toBe(false)

    it "should return false if no user is logged in", ->
      authentication.clearCurrentUser()
      expect(authentication.isAdmin()).toBe(false)
