angular.module('ChefStepsApp').directive 'csNotifications', (csAlertService) ->
  restrict: 'E'
  # transclude: true
  link: (scope, element, attrs) ->
    scope.alerts = csAlertService
  template: '
    <div class="alert alert-block" ng-repeat="alert in alerts.getAlerts()" ng-class="\'alert-\' + (alert.type || \'error\')" close="alerts.closeAlert($index)" ng-animate="custom">
      <button type="button" class="close" ng-click="alerts.closeAlert($index)">&times;</button>
      <h4>{{alert.message}}</h4>
      <div class="lblock"></div>
    </div>
  '