describe "csIntent", ->
  csIntent = {}

  beforeEach ->
    module('ChefStepsApp')
    inject ($injector) ->
      csIntent = $injector.get('csIntent')

  describe 'setIntent', ->
    it 'should set the intent', ->
      csIntent.setIntent('ftue')
      expect(csIntent.intent).toEqual('ftue')

  describe 'clearIntent', ->
    it 'should clear the intent', ->
      csIntent.clearIntent()
      expect(csIntent.intent).toEqual({})
