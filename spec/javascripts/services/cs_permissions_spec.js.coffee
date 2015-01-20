describe 'csPermissions', ->

  permissions = null

  beforeEach ->
    module('ChefStepsApp')

    inject (csPermissions) ->
      permissions = csPermissions

  it "should initialize", ->
    expect(permissions).toNotBe(null)

  describe "#sendFreeGift", ->

    it "should return true if user role is admin", ->
      permissions.auth.setCurrentUser({email: "admin@chefsteps.com", role: "admin"})
      expect(permissions.check('sendFree gifts')).toBe(true)

    it "should return true if user role is collaborator", ->
      permissions.auth.setCurrentUser({email: "admin@chefsteps.com", role: "collaborator"})
      expect(permissions.check('sendFree gifts')).toBe(true)

    it "should return false if no user is present", ->
      expect(permissions.check('sendFree gifts')).toBe(false)
