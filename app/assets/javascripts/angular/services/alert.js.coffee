angular.module('ChefStepsApp').service 'csAlertService',  ->
  this.addAlert = (alert, $scope, $timeout) ->
    $scope.alerts.push(alert)
    $timeout ->
      $("html, body").animate({ scrollTop: -500 }, "slow")

  this.closeAlert = (index, $scope) ->
    $scope.closeAlert = (index) ->
      $scope.alerts.splice(index, 1)
