describe 'csDataLoading', ->
  dataLoading = null
  rootScope = null
  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach ->
    module('ChefStepsApp')
    inject ($injector) ->
      rootScope = $injector.get '$rootScope'
      spyOn rootScope, '$broadcast'

    inject (csDataLoading) ->
      dataLoading = csDataLoading

  # now run that scope through the controller function,
  # injecting any services or other injectables we need.
  it "should initialize", ->
    expect(dataLoading).toNotBe(null)

  describe "#start", ->
    it "should start showing as isLoading", ->
      dataLoading.start()
      expect(dataLoading.isLoading()).toBe(true)
    it "should increment the dataLoading variable", ->
      dataLoading.start()
      expect(dataLoading.loading()).toBe(1)
      dataLoading.start()
      expect(dataLoading.loading()).toBe(2)

  describe "#stop", ->
    it "should start showing as isLoading", ->
      dataLoading.start()
      expect(dataLoading.isLoading()).toBe(true)
      dataLoading.stop()
      expect(dataLoading.isLoading()).toBe(false)
    it "should increment the dataLoading variable", ->
      dataLoading.start()
      expect(dataLoading.loading()).toBe(1)
      dataLoading.stop()
      expect(dataLoading.loading()).toBe(0)

  describe "#stopAll", ->
    it "should stop all loading", ->
      dataLoading.start()
      dataLoading.start()
      expect(dataLoading.isLoading()).toBe(true)
      dataLoading.stopAll()
      expect(dataLoading.isLoading()).toBe(false)
    it "should reset the dataLoading variable", ->
      dataLoading.start()
      dataLoading.start()
      expect(dataLoading.loading()).toBe(2)
      dataLoading.stopAll()
      expect(dataLoading.loading()).toBe(0)

  describe "#isLoading", ->
    it "should return true if loading", ->
      dataLoading.start()
      expect(dataLoading.isLoading()).toBe(true)
    it "should return false if not loading", ->
      dataLoading.start()
      expect(dataLoading.isLoading()).toBe(true)
      dataLoading.stopAll()
      expect(dataLoading.isLoading()).toBe(false)

