describe 'ChefSteps.Router', ->
  beforeEach ->
    @fake_user = jasmine.createSpy('fake user')
    @fake_user.id = 123
    @router = new ChefSteps.Router(currentUser: @fake_user, registrationCompletionPath: 'path')

  describe "#initialize", ->
    it "sets the current user", ->
      expect(@router.currentUser).toEqual(@fake_user)

  describe "#loadHeader", ->
    beforeEach ->
      @fake_header = jasmine.createSpyObj('fake header', ['render'])
      spyOn(ChefSteps, 'new').andReturn(@fake_header)
      @router.loadHeader()

    it "instantiates the profile header view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ProfileHeader, model: @router.currentUser)

    it "renders on the header view", ->
      expect(@fake_header.render).toHaveBeenCalled()

  describe "#showProfile", ->
    beforeEach ->
      spyOn(ChefSteps.Views, 'Profile')

    it "does not create profile view if currentUser doesn't exist", ->
      @router.showProfile()
      expect(ChefSteps.Views.Profile).not.toHaveBeenCalled()

    it "does not create profile view if currentUser id doesn't match id param", ->
      @router.showProfile('1')
      expect(ChefSteps.Views.Profile).not.toHaveBeenCalled()

    describe "if currentUser id matches id param", ->
      beforeEach ->
        @router.showProfile('123')

      it "creates profile view", ->
        expect(ChefSteps.Views.Profile).toHaveBeenCalled()

      it "creates view with newUser undefined if new_user is not set", ->
        @router.showProfile('123')
        expect(ChefSteps.Views.Profile.mostRecentCall.args[0].newUser).toBeUndefined()

      it "creates view with newUser defined", ->
        @router.showProfile('123', new_user: '1')
        expect(ChefSteps.Views.Profile.mostRecentCall.args[0].newUser).toEqual('1')

  describe "#startQuizApp", ->
    beforeEach ->
      spyOn(ChefSteps.Views, 'Quiz')

    it 'passes completion path to quiz view', ->
      @router.startQuizApp('123')
      expect(ChefSteps.Views.Quiz.mostRecentCall.args[0].quizCompletionPath).toEqual('/quizzes/123/results')

    it 'passes completion path with token to quiz view if token provided', ->
      @router.startQuizApp('123', token: 'ABC')
      expect(ChefSteps.Views.Quiz.mostRecentCall.args[0].quizCompletionPath).toEqual('/quizzes/123/results?token=ABC')
