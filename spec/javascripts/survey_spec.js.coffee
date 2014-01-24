
describe 'SurveyController', ->
  scope = {}
  controller = {}

  beforeEach(module('ChefStepsApp'))

  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    controller = $controller('SurveyController', {$scope: scope})

  describe "#update", ->
    it "returns a JSON objet with answers", inject ($rootScope, $controller) ->
      console.log 'hello'


