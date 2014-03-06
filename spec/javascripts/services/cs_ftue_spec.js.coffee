describe "csFtue", ->
  csFtue = {}
  rootScope = {}

  beforeEach ->
    module('ChefStepsApp')
    inject ($injector) ->
      csFtue = $injector.get('csFtue')
      rootScope = $injector.get('$rootScope')
    spyOn(rootScope, '$emit')

  describe 'open', ->
    it 'should open the current item', ->
      csFtue.open('Recommendations')
      expect(rootScope.$emit).toHaveBeenCalledWith('openRecommendations', {intent: 'ftue'})

  describe 'prev', ->
    it 'should open the previous item', ->
      csFtue.current = { name: 'Recommendations', title: 'Here are some recipes.' }
      csFtue.currentIndex = 2
      csFtue.prev()
      expect(rootScope.$emit).toHaveBeenCalledWith('openInvite', {intent: 'ftue'})

  describe 'next', ->
    it 'should open the previous item', ->
      csFtue.current = { name: 'Recommendations', title: 'Here are some recipes.' }
      csFtue.currentIndex = 2
      csFtue.next()
      expect(rootScope.$emit).toHaveBeenCalledWith('openWelcome', {intent: 'ftue'})

  describe 'indexOfItem', ->
    it 'should return the correct index of an item', ->
      item = {name: 'Recommendations', title: 'Get Started'}
      expect(csFtue.indexOfItem(item)).toBe(2)