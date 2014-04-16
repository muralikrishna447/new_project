@app.controller 'PopupCTAController', ["$scope", "$rootScope", "csAuthentication", "localStorageService", ($scope, $rootScope, csAuthentication, localStorageService) ->

  # Really want to make this a nell popup, but the contents aren't angularized.
  # Got part way down the road and it was turning into too big a hassle. So for now,
  # they interlock with two booleans on the root scope to avoid both being up at the same time.
  $scope.$on 'showPopupCTA', ->
    return if localStorageService.get('madlibPopupShown')

    if ! $scope.showPopup && ! $scope.editMode && ! csAuthentication.currentUser() && ! $rootScope.nellPopupShowing
      $rootScope.showMadlibPopup = true
      localStorageService.set('madlibPopupShown', true)
      mixpanel.track('Popup CTA Shown', _.extend({source : $scope.registrationSource}, $rootScope.splits))

  $scope.shouldShowPopupCTA = ->
    $rootScope.showMadlibPopup

  $scope.hidePopupCTA = ->
    $rootScope.showMadlibPopup = false
]