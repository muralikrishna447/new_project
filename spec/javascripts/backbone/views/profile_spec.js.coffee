describe 'ChefSteps.Views.Profile', ->
  beforeEach ->
    spyOn(ChefSteps, 'new').andCallFake (klass) ->
      switch klass
        when ChefSteps.Views.EditProfile
          @fake_edit_profile_view = jasmine.createSpyObj('fake edit profile view', ['show', 'hide', 'getProfileValues'])
        when ChefSteps.Views.ShowProfile
          @fake_profile_bio_view = jasmine.createSpyObj('fake bio view', ['show', 'hide', 'checkEmptyValues'])

    @fake_user = jasmine.createSpyObj('fake user', ['save', 'attributes', 'on'])
    @view = new ChefSteps.Views.Profile(model: @fake_user, registrationCompletionPath: 'path')

  describe '#initialize', ->
    it "instantiates the bio view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ShowProfile, {model: @fake_user, el: '.user-profile-bio'})

    it "instantiates the edit profile view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.EditProfile, {model: @fake_user, el: '.edit-user-profile'})

    it "checks for empty values", ->
      expect(@view.showProfileView.checkEmptyValues).toHaveBeenCalled()

    it "assigns registrationCompletionPath", ->
      expect(@view.registrationCompletionPath).toEqual 'path'

    it "adds listener to model's 'change:profile_complete' event", ->
      expect(@fake_user.on).toHaveBeenCalledWith('change:profile_complete', @view.profileCompleteChange, @view)

  describe "events", ->
    it "shows edit profile when edit is click", ->
      expect(@view.events).toEqual
        "click .edit-profile": "showEditProfile"
        "click .save-profile": "saveProfile"
        "click .edit-profile-cancel": "showProfile"

  describe "#showEditProfile", ->
    beforeEach ->
      @view.showEditProfile()

    it "shows the edit profile view", ->
      expect(@view.editProfileView.show).toHaveBeenCalled()

    it "hides the profile bio view", ->
      expect(@view.showProfileView.hide).toHaveBeenCalled()

  describe "#showProfile", ->
    beforeEach ->
      @view.showProfile()

    it "shows the profile bio view", ->
      expect(@view.showProfileView.show).toHaveBeenCalled()

    it "hides the edit profile view", ->
      expect(@view.editProfileView.hide).toHaveBeenCalled()

  describe "#saveProfile", ->
    beforeEach ->
      @view.editProfileView.getProfileValues.andReturn('some values')
      spyOn(@view, 'showProfile')
      @view.saveProfile()

    it "gets the profile values from edit view", ->
      expect(@view.editProfileView.getProfileValues).toHaveBeenCalled()

    it "saves the values to the model", ->
      expect(@fake_user.save).toHaveBeenCalledWith('some values')

    it "shows the profile bio view", ->
      expect(@view.showProfile).toHaveBeenCalled()

    it "hides empty fields", ->
      expect(@view.showProfileView.checkEmptyValues).toHaveBeenCalled()

