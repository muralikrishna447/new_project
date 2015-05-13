# There should only be one of these on a page, it is intended as a singleton
@app.directive 'nellPopup', ["$rootScope", "Ingredient", "Activity", "$timeout", "csUtilities", ($rootScope, Ingredient, Activity, $timeout, csUtilities) ->
  restrict: 'A'
  scope: true
  replace: true


  link: ($scope, $element, $attrs) ->
    $scope.csUtilities = csUtilities

    $scope.$on 'showNellPopup', (event, _info) ->
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
          $scope.obj.hasVideo = $scope.obj.youtube_id || $scope.obj.vimeo_id
          $scope.nellLoading = false
        )

    $scope.getClass = ->
      classes = ['nell-popup']
      classes.push('active') if $rootScope.nellPopupShowing
      classes.push($scope.info.extraClass) if $scope.info?.extraClass
      classes

    $scope.closeNellPopup = ->
      $scope.info.closeCallback() if $scope.info?.closeCallback
      $rootScope.nellPopupShowing = false

    $scope.doHideNellPopup = ->
      $scope.closeNellPopup()
      mixpanel.track 'Nell Closed', $scope.info

    $scope.abandonNellPopup = ->
      $scope.closeNellPopup()
      mixpanel.track 'Nell Abandoned', $scope.info

    $scope.$on 'hideNellPopup', (event) ->
      $scope.doHideNellPopup()

    $scope.outclickProduct = ->
      window.open($scope.obj.product_url, '_blank')
      mixpanel.track('Buy Clicked', {source: 'nellCard', 'productSlug' : $scope.info.slug});


  template: '''
    <div>
      <div class="nell-backdrop" ng-click='abandonNellPopup()' ng-show='nellPopupShowing'/>
      <div ng-class="getClass()">
        <div class='close-x' ng-click='abandonNellPopup()' ng-show='nellPopupShowing && ! nellLoading'>
          <i class='icon-remove'/>
        </div>
        <cs-loading-spinner ng-hide="! nellLoading"/>
        <div ng-include='info.include' ng-hide="nellLoading"/>
      </div>
    </div>
  '''
]