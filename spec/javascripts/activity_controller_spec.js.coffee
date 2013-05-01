
describe 'ActivityController', ->
  beforeEach(module('ChefStepsApp'))

  beforeEach inject(($httpBackend) ->
    $httpBackend.whenGET('/activities/1').respond([])
  )

  # Total hack
  $('html').append("<div id='activity-body' data-activity-id='1'></div>")

  describe "#startEditMode", ->
    it "puts the app into edit mode", inject ($rootScope, $controller) ->
      scope = $rootScope.$new()
      ctrl = $controller('ActivityController', {$scope: scope})
      scope.startEditMode()
      expect(scope.editMode).toBeTruthy()
      scope.cancelEditMode()
      expect(scope.editMode).toBeFalsy()
