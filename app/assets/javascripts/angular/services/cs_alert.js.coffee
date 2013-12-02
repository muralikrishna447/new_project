angular.module('ChefStepsApp').service 'csAlertService',  ->
  this.alerts = []

  this.addAlert = (alert, $timeout) ->
    this.alerts.push(alert)
    $timeout ->
      $("html, body").animate({ scrollTop: -500 }, "slow")

  this.closeAlert = (index) ->
    this.alerts.splice(index, 1)

  this.getAlerts = ->
    this.alerts
