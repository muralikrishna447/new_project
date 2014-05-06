# There should only be one of these on a page, it is intended as a singleton
@app.directive 'nellPopup', ["$rootScope", "Ingredient", "Activity", "$timeout", "csUtilities", ($rootScope, Ingredient, Activity, $timeout, csUtilities) ->
  restrict: 'A'
  scope: true
  replace: true


  link: ($scope, $element, $attrs) ->
    $scope.csUtilities = csUtilities
    
    $scope.$on 'showNellPopup', (event, _info) ->
      return if $scope.editMode
      return if $rootScope.showMadlibPopup
      return if $rootScope.nellPopupShowing && (_info.include == $scope.info.include) && (_info.slug == $scope.info.slug)

      $scope.info = _info

      # This could be in a service, though I don't see all that much advantage
      $rootScope.nellPopupShowing = true
      mixpanel.track 'Nell Shown', $scope.info
      
      $scope.obj = null
      if $scope.info.resourceClass
        $scope.nellLoading = true
        $scope.obj = eval($scope.info.resourceClass).get_as_json({id: $scope.info.slug}, ->
          $scope.nellLoading = false
        )

    $scope.getClass = ->
      return ['nell-popup', 'active'] if $rootScope.nellPopupShowing
      return 'nell-popup'

    $scope.doHideNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Closed', $scope.info

    $scope.abandonNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Abandoned', $scope.info

    $scope.$on 'hideNellPopup', (event) ->
      $scope.doHideNellPopup()


  template: '''
    <div>
      <div class="nell-backdrop" ng-click='abandonNellPopup()' ng-show='nellPopupShowing'/>
      <div ng-class="getClass()">
        <div class='close-x' ng-click='abandonNellPopup()' ng-show='nellPopupShowing && ! nellLoading'>
          <i class='icon-remove'/>
        </div>
        <div class="activity-loading-spinner" ng-if="nellLoading">
          <i class='icon-page-load'/>
        </div>
        <div ng-include='info.include'/ ng-hide="nellLoading">
      </div>
    </div>
  '''
]