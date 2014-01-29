angular.module('ChefStepsApp').directive 'csNotifications', ["csAlertService", (csAlertService) ->
  restrict: 'E'
  # transclude: true
  link: (scope, element, attrs) ->
    scope.alerts = csAlertService
  template: '
    <div class="alert alert-block anim-basic-fade" ng-repeat="alert in alerts.getAlerts()" ng-class="\'alert-\' + (alert.type || \'error\')" close="alerts.closeAlert($index)">
      <button type="button" class="close" ng-click="alerts.closeAlert($index)">&times;</button>
      <h4 ng-class="alert.class" ng-bind-html-unsafe="alert.message"></h4>
      <div class="lblock"></div>
    </div>
  '
]