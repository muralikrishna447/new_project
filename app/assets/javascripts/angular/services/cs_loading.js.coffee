angular.module('ChefStepsApp').directive 'csLoading', ["csDataLoading", (csDataLoading) ->
  restrict: 'E'
  # transclude: true
  link: (scope, element, attrs) ->
    scope.dataLoading = csDataLoading
  template: '
    <div class="logo-box">
      <div class="regular-logo" ng-hide="dataLoading.isLoading()">
        <img src="https://s3.amazonaws.com/chefsteps/static/csLogoHorizontalSmall.svg", id="chefsteps-logo" />
      </div>
      <div class="loading-logo" ng-show="dataLoading.isLoading() && !dataLoading.isFullScreen()">
        <img src="https://s3.amazonaws.com/chefsteps/static/csLogoLoading.gif", id="chefsteps-logo-loading" />
      </div>
      <div class="loading-no-logo" ng-show="dataLoading.isLoading() && dataLoading.isFullScreen()">
        <img src="https://s3.amazonaws.com/chefsteps/static/csLoadingIcon.gif", id="chefsteps-no-logo-loading" />
      </div>
    </div>
  '
]