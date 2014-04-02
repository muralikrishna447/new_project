@app.controller 'PopupCTAController', ["$scope", "$rootScope", "csAuthentication", ($scope, $rootScope, csAuthentication) ->

  $scope.showPopup = null

  $scope.$on 'showPopupCTA', ->
    # Note tri-state, won't reshow once it becomes false
    whyBy = $scope.viewOptions? && $scope.viewOptions.showWhyByWeight
    if $scope.showPopup == null && ! $scope.editMode && ! csAuthentication.currentUser() && ! whyBy
      $scope.showPopup = true 
      mixpanel.track('Popup CTA Shown', _.extend({source : $scope.registrationSource}, $rootScope.splits))

  $scope.shouldShowPopupCTA = ->
    $scope.showPopup

  $scope.hidePopupCTA = ->
    $scope.showPopup = false
]