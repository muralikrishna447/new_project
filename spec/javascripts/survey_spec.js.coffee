
describe 'SurveyController', ->
  scope = {}
  controller = {}

  beforeEach(module('ChefStepsApp'))

  beforeEach inject ($rootScope, $controller) ->
    scope = $rootScope.$new()
    controller = $controller('SurveyController', {$scope: scope})
    scope.questions = []

  describe "#getResults", ->
    describe "when question has a type of select", ->
      beforeEach ->
        scope.question = {}
        scope.question.type = 'select'
        scope.question.copy = 'I am a select question, right?'
        scope.question.answer = 'Yes, you are a select question.'
        scope.questions.push(scope.question)

      it "returns the correct answer", ->
        scope.getResults()
        expect(scope.survey_results['I am a select question, right?']).toBe('Yes, you are a select question.')

    describe "when a question has a type of multiple-select", ->
      beforeEach ->
        scope.question = {}
        scope.question.type = 'multiple-select'
        scope.question.copy = 'I am a multiple-select question.'
        scope.question.options = [
          { name: 'red', checked: true }
          { name: 'blue', checked: true }
          { name: 'purple', checked: false }
        ]
        scope.questions.push(scope.question)

      it "returns the correct answer", ->
        scope.getResults()
        expect(scope.survey_results['I am a multiple-select question.']).toBe('red,blue')

    describe "when a question has a type of open-ended", ->
      beforeEach ->
        scope.question = {}
        scope.question.type = 'open-ended'
        scope.question.copy = 'Tell me a story.'
        scope.question.answer = 'Once upon a time there was a Chef.'
        scope.questions.push(scope.question)

      it "returns the correct answer", ->
        scope.getResults()
        expect(scope.survey_results['Tell me a story.']).toBe('Once upon a time there was a Chef.')

  describe "#update", ->
    it "returns a JSON object with answers", inject ($rootScope, $controller) ->
      console.log 'hello'


