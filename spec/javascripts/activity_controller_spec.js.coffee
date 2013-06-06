
describe 'ActivityController', ->
  scope = {}
  ctrl = {}

  # Total hack
  $('html').append("<div id='activity-body' data-activity-id='1'></div><div id='preloaded-activity-json'>{&quot;activity_order&quot;:null,&quot;activity_type&quot;:[&quot;Recipe&quot;],&quot;assignment_recipes&quot;:null,&quot;cooked_this&quot;:0,&quot;created_at&quot;:&quot;2013-04-19T18:31:58Z&quot;,&quot;description&quot;:&quot;&quot;,&quot;difficulty&quot;:&quot;intermediate&quot;,&quot;featured_image_id&quot;:&quot;&quot;,&quot;id&quot;:295,&quot;image_id&quot;:&quot;&quot;,&quot;last_edited_by_id&quot;:10,&quot;published&quot;:true,&quot;slug&quot;:&quot;original&quot;,&quot;source_activity_id&quot;:null,&quot;source_type&quot;:0,&quot;timing&quot;:&quot;&quot;,&quot;title&quot;:&quot;original&quot;,&quot;transcript&quot;:&quot;&quot;,&quot;updated_at&quot;:&quot;2013-06-05T23:13:32Z&quot;,&quot;yield&quot;:&quot;&quot;,&quot;youtube_id&quot;:&quot;&quot;,&quot;tags&quot;:[{&quot;id&quot;:42,&quot;name&quot;:&quot;fish&quot;},{&quot;id&quot;:261,&quot;name&quot;:&quot;fries&quot;},{&quot;id&quot;:265,&quot;name&quot;:&quot;frying&quot;},{&quot;id&quot;:266,&quot;name&quot;:&quot;main dishes&quot;},{&quot;id&quot;:274,&quot;name&quot;:&quot;french&quot;},{&quot;id&quot;:275,&quot;name&quot;:&quot;fatty&quot;},{&quot;id&quot;:276,&quot;name&quot;:&quot;rich&quot;}],&quot;equipment&quot;:[],&quot;ingredients&quot;:[],&quot;steps&quot;:[]}</div> ")

  beforeEach(module('ChefStepsApp'))

  #beforeEach inject(($httpBackend) ->
  #  $httpBackend.whenGET('/activities/1/as_json').respond({"title" : "original"})
  #)

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


