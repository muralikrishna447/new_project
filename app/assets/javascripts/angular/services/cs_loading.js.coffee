angular.module('ChefStepsApp').directive 'csLoading', ["csDataLoading", (csDataLoading) ->
  restrict: 'E'
  # scope: true
  transclude: true
  link: (scope, element, attrs) ->
    scope.dataLoading = csDataLoading
  template: '
    <div class="logo-box">
      <div ng-class="{\'is-loading\': dataLoading.isLoading(), \'is-fullscreen\': dataLoading.isFullScreen()}">
        <img class="regular-logo" src="https://s3.amazonaws.com/chefsteps/static/chefsteps-logo-h-tagline.png", id="chefsteps-logo" width="200" />
        <img class="loading-logo" src="https://s3.amazonaws.com/chefsteps/static/csLogoLoading.gif" />
        <div class="loading-no-logo">
          <img src="https://s3.amazonaws.com/chefsteps/static/csLoadingIcon.gif", id="chefsteps-no-logo-loading" />
        </div>
      </div>
    </div>
  '
]