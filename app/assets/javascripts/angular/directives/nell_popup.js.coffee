# There should only be one of these on a page, it is intended as a singleton
@app.directive 'nellPopup', ["$rootScope", ($rootScope) ->
  restrict: 'A'
  scope: true

  link: ($scope, $element, $attrs) ->
    $scope.$on 'showNellPopup', (event, info) ->
      $scope.info = info
      $scope.contents = $scope.info.include
      # This could be in a service, though I don't see all that much advantage
      $rootScope.nellPopupShowing = true
      mixpanel.track 'Nell Shown', $scope.info

    $scope.hideNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Closed', $scope.info

    $scope.abandonNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Abandoned', $scope.info

    $scope.$on 'hideNellPopup', (event) ->
      $scope.hideNellPopup()

  template: '''
    <div class='nell-popup' ng-show="nellPopupShowing">
      <div class='top-triangle'>
        <i class="icon-caret-up"/>
      </div>
      <div class='close-x' ng-click='abandonNellPopup()'>
        <i class='icon-remove'/>
      </div>
      <div ng-include='contents'/>
    </div>
  '''
]