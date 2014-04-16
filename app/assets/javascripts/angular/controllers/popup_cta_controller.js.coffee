@app.controller 'PopupCTAController', ["$scope", "$rootScope", "csAuthentication", "localStorageService", ($scope, $rootScope, csAuthentication, localStorageService) ->

  $scope.showPopup = false

  $scope.$on 'showPopupCTA', ->
    return if localStorageService.get('madlibPopupShown')

    if ! $scope.showPopup && ! $scope.editMode && ! csAuthentication.currentUser() && ! $rootScope.nellPopupShowing
      $scope.showPopup = true 
      localStorageService.set('madlibPopupShown', true)
      mixpanel.track('Popup CTA Shown', _.extend({source : $scope.registrationSource}, $rootScope.splits))

  $scope.shouldShowPopupCTA = ->
    $scope.showPopup

  $scope.hidePopupCTA = ->
    $scope.showPopup = false
]