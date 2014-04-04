# There should only be one of these on a page, it is intended as a singleton
@app.directive 'nellPopup', ["$rootScope", "Ingredient", "Activity", ($rootScope, Ingredient, Activity) ->
  restrict: 'A'
  scope: true
  replace: true

  link: ($scope, $element, $attrs) ->
    $scope.$on 'showNellPopup', (event, _info) ->
      return if $scope.editMode
      return if $rootScope.nellPopupShowing && (_info.include == $scope.info.include) && (_info.slug == $scope.info.slug)

      $scope.info = _info
      # This could be in a service, though I don't see all that much advantage
      $rootScope.nellPopupShowing = true
      mixpanel.track 'Nell Shown', $scope.info
      $scope.obj = null
      if $scope.info.resourceClass == 'Ingredient'
        $scope.obj = Ingredient.get_as_json({id: $scope.info.slug})
      else if $scope.info.resourceClass == "Activity"
        $scope.obj = Activity.get_as_json({id: $scope.info.slug})
      $element.addClass('active')

    $scope.getClass = ->
      return ['nell-popup', 'active'] if $rootScope.nellPopupShowing
      return 'nell-popup'

    $scope.hideNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Closed', $scope.info
      $element.removeClass('active')

    $scope.abandonNellPopup = ->
      $rootScope.nellPopupShowing = false
      mixpanel.track 'Nell Abandoned', $scope.info

    $scope.$on 'hideNellPopup', (event) ->
      $scope.hideNellPopup()

    $scope.imageURL = (imageID) ->
      url = ""
      if imageID
        url = JSON.parse(imageID).url
        url = url + "/convert?fit=max&w=480&cache=true"
      window.cdnURL(url)


  template: '''
    <div ng-class="getClass()">
      <div class='close-x' ng-click='abandonNellPopup()'>
        <i class='icon-remove'/>
      </div>
      <div ng-include='info.include'/>
    </div>
  '''
]