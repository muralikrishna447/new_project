describe 'ActivityController', ->

  describe "#startEditMode", ->
    it "puts the app into edit mode", ->
      scope = {}
      ctrl = new ActivityController(scope)
      expect(scope.editMode).toBeTruthy()
