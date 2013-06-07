
describe 'ActivityController', ->
  scope = {}
  ctrl = {}

  # Total hack
  $('html').append("<div id='activity-body' data-activity-id='1'></div>")

  beforeEach(module('ChefStepsApp'))

  beforeEach inject(($httpBackend) ->
    $httpBackend.whenGET('/activities/1/as_json').respond({"title" : "original"})
  )

  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    ctrl = $controller('ActivityController', {$scope: scope})
    # Hack b/c I can't get the respond() above to do anything apparently
    scope.activity.title = "original"

  describe "#startEditMode", ->
    it "puts the app into edit mode", inject ($rootScope, $controller) ->
      scope.startEditMode()
      expect(scope.editMode).toBeTruthy()

  describe "#endEditMode", ->
    it "end edit mode with change committed", inject ($rootScope, $controller, $httpBackend) ->
      scope.startEditMode()
      scope.activity.title = "foobar"
      $httpBackend.expectPUT('/activities/1/as_json').respond(201, '')
      scope.endEditMode()
      expect(scope.activity.title).toEqual("foobar")
      expect(scope.editMode).toBeFalsy()

  describe "#cancelEditMode", ->
    it "cancels edit mode with no changes", inject ($rootScope, $controller) ->
      scope.startEditMode()
      scope.activity.title = "foobar"
      scope.cancelEditMode()
      expect(scope.activity.title).toEqual("original")
      expect(scope.editMode).toBeFalsy()

  describe "undo/redo sequence", ->
    it "handles undo and redo commands as expected", ->
      scope.startEditMode()
      expect(scope.undoAvailable()).toBeFalsy()
      scope.activity.title = "foobar1"
      scope.addUndo()
      scope.activity.title = "foobar2"
      scope.addUndo()
      expect(scope.undoAvailable()).toBeTruthy()
      expect(scope.redoAvailable()).toBeFalsy()
      scope.undo()
      expect(scope.activity.title).toEqual("foobar1")
      expect(scope.undoAvailable()).toBeTruthy()
      expect(scope.redoAvailable()).toBeTruthy()
      scope.redo()
      expect(scope.activity.title).toEqual("foobar2")
      scope.undo()
      scope.undo()
      expect(scope.activity.title).toEqual("original")
      expect(scope.undoAvailable()).toBeFalsy()
      expect(scope.redoAvailable()).toBeTruthy()


