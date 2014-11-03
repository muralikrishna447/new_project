angular.module('ChefStepsApp').directive 'csLoading', ["csDataLoading", (csDataLoading) ->
  restrict: 'E'
  # scope: true
  transclude: true
  link: (scope, element, attrs) ->
    scope.dataLoading = csDataLoading
  template: '
    <div class="logo-box">
      <div ng-class="{\'is-loading\': dataLoading.isLoading(), \'is-fullscreen\': dataLoading.isFullScreen()}">
        <img class="regular-logo" src="https://d92f495ogyf88.cloudfront.net/static/chefsteps-logo-h-tagline.png", id="chefsteps-logo" />
        <img class="loading-logo" src="https://d92f495ogyf88.cloudfront.net/static/csLogoLoading.gif" />
        <div class="loading-no-logo">
          <img src="https://d92f495ogyf88.cloudfront.net/static/csLoadingIcon.gif", id="chefsteps-no-logo-loading" />
        </div>
      </div>
    </div>
  '
]