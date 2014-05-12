describe "InviteController", ->
  scope = {}
  controller = {}
  rootScope = {}
  intent = {}

  fakeModal =
    command: null
    modal: (command) ->
      @command = command

  fakePromise = then: (callback) ->
    callback fakeModal

  beforeEach(angular.mock.module('ChefStepsApp'))

  beforeEach(angular.mock.inject( ($controller, $rootScope) ->
    scope = $rootScope.$new()
    modalInstance = jasmine.createSpy("$modalInstance").andReturn(fakePromise)
    authentication = jasmine.createSpy("csAuthentication")
    alertService = jasmine.createSpyObj('csAlertService', ['addAlert', 'getAlerts'])
    urlService = jasmine.createSpy("csUrlService")
    facebook =
      connect: jasmine.createSpy("connect").andReturn(fakePromise)
      friendInvites: jasmine.createSpy("friendInvites").andReturn(fakePromise)

    $controller("InviteController", {
      $scope: scope
      $modalInstance: modalInstance
      $rootScope: $rootScope
      intent: intent
      csAuthentication: authentication
      csFacebook: facebook
      csAlertService: alertService
      csUrlService: urlService

    })
  ))

  describe "$on", ->
    beforeEach ->
