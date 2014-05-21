@app.service 'csAlertService', ["$rootScope", "$timeout", ($rootScope, $timeout) ->
  this.alerts = []

  this.addAlert = (alert) ->
    this.alerts.push(alert)
    $rootScope.$broadcast "showNellPopup", 
      include: '_alerts_popup.html'
      extraClass: 'alert-popup'
      closeCallback: => this.alerts = []

  this.getAlerts = ->
    this.alerts

  $timeout ( =>
    railsFlash = $("#rails-flash").text()
    if railsFlash.length > 0
        for alert in JSON.parse(railsFlash)
          this.addAlert
            message: alert[1]
            class: alert[0]
    ), 500
  this
]