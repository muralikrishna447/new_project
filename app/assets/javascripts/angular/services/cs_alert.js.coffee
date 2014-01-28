angular.module('ChefStepsApp').service 'csAlertService', ["$timeout", ($timeout) ->
  this.alerts = []

  this.addAlert = (alert, oldTimeoutObject='') ->
    this.alerts.push(alert)
    $timeout ->
      $("html, body").animate({ scrollTop: -500 }, "slow")

  this.closeAlert = (index) ->
    this.alerts.splice(index, 1)

  this.getAlerts = ->
    this.alerts

  this
]