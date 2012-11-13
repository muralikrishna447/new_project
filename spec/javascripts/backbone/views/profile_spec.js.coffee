describe 'ChefSteps.Views.Profile', ->
  beforeEach ->
    spyOn(ChefSteps, 'new').andCallFake (klass) ->
      switch klass
        when ChefSteps.Views.EditProfile
          @fake_edit_profile_view = jasmine.createSpyObj('fake edit profile view', ['show', 'hide', 'getProfileValues'])
        when ChefSteps.Views.ProfileBio
          @fake_profile_bio_view = jasmine.createSpyObj('fake bio view', ['show', 'hide'])

    @fake_user = jasmine.createSpyObj('fake user', ['save', 'attributes'])
    @view = new ChefSteps.Views.Profile(model: @fake_user)

  describe '#initialize', ->
    it "instantiates the bio view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ProfileBio, {model: @fake_user, el: '.user-profile-bio'})

    it "instantiates the edit profile view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.EditProfile, {model: @fake_user, el: '.edit-user-profile'})

  describe "events", ->
    it "shows edit profile when edit is click", ->
      expect(@view.events).toEqual
        "click .edit-profile": "showEditProfile"
        "click .save-profile": "saveProfile"

  describe "#showEditProfile", ->
    beforeEach ->
      @view.showEditProfile()

    it "shows the edit profile view", ->
      expect(@view.editProfileView.show).toHaveBeenCalled()

    it "hides the profile bio view", ->
      expect(@view.profileBioView.hide).toHaveBeenCalled()

  describe "#showProfileBio", ->
    beforeEach ->
      @view.showProfileBio()

    it "shows the profile bio view", ->
      expect(@view.profileBioView.show).toHaveBeenCalled()

    it "hides the edit profile view", ->
      expect(@view.editProfileView.hide).toHaveBeenCalled()

  describe "#saveProfile", ->
    beforeEach ->
      @view.editProfileView.getProfileValues.andReturn('some values')
      spyOn(@view, 'showProfileBio')
      @view.saveProfile()

    it "gets the profile values from edit view", ->
      expect(@view.editProfileView.getProfileValues).toHaveBeenCalled()

    it "saves the values to the model", ->
      expect(@fake_user.save).toHaveBeenCalledWith('some values')

    it "shows the profile bio view", ->
      expect(@view.showProfileBio).toHaveBeenCalled()

