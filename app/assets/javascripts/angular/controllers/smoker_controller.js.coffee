

angular.module('ChefStepsApp').controller 'SmokerController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "$anchorScroll", ($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, $anchorScroll) ->
  $scope.smokeState = false
  $scope.fanState = false
  $scope.probe1Temp = "--"
  $scope.probe2Temp = "--"
  $scope.pauseLoad = false

  $scope.getState = ->
    $scope.loading = true if ! $scope.pauseLoad
    $http.get("https://agent.electricimp.com/VfTPvDypa0TD?getState").success (data, status) ->
      $scope.state = data if ! $scope.pauseLoad
      $timeout (-> $scope.loading = false), 500
      $timeout (-> $scope.getState()), 1000
      $scope.chart.data.rows.push({c: [{v: new Date()}, {v: $scope.state.temperatureValue}]})
      $scope.chartRH.data.rows.push({c: [{v: new Date()}, {v: $scope.state.humidityValue}]})

  # boostrap the polling
  $scope.getState()

  $scope.$watch 'state.temperatureSetPoint', ((newValue, oldValue) ->
    if newValue != oldValue
      $timeout (->
        console.log "setting temp " + $scope.state.temperatureSetPoint
        $http.get("https://agent.electricimp.com/VfTPvDypa0TD?temperatureSetPoint=" + $scope.state.temperatureSetPoint).error (data, status) ->
          console.log(data)
      ), 2000
  )

  $scope.$watch 'state.humiditySetPoint', ((newValue, oldValue) ->
    if newValue != oldValue
      $timeout (->
        console.log "setting humidity " + $scope.state.humiditySetPoint
        $http.get("https://agent.electricimp.com/VfTPvDypa0TD?humiditySetPoint=" + $scope.state.humiditySetPoint).error (data, status) ->
          console.log(data)
      ), 2000
  )

  # http://andrew.rsmas.miami.edu/bmcnoldy/Humidity.html
  # Note!! Using the equation he specs, but it doesn't match what his calculator computes!
  # Results do seem to match against http://www.decatur.de/javascript/dew/ and 
  # http://www.hpc.ncep.noaa.gov/
  $scope.wetBulb = ->
    return if ! $scope.state?
    RH = $scope.state.humidityValue
    T = $scope.state.temperatureValue
    LN = Math.log
    TD = 243.04 * (LN(RH/100)+((17.625*T)/(243.04+T)))/(17.625-LN(RH/100)-((17.625*T)/(243.04+T)))
    Math.round(TD * 10) / 10

  $scope.colorClass = (v1, v2) ->
    return "tooLow" if v1 > v2
    return "tooHigh" if v1 < v2
    return "justRight"

  $scope.chart =
    type: "LineChart"
    displayed: true
    cssStyle: "height:100px; width:100px;"
    data:
      cols: [
        id: "time"
        label: "Time"
        type: "datetime"
      ,
        id: "temperature"
        label: "temperature"
        type: "number"
      ]
      rows: [
      ]

    options:
      title: ""
      isStacked: "true"
      xfill: 20
      displayExactValues: true
      curveType: "function"
      vAxis:
        minValue: 22
        maxValue: 23
        title: ""
        gridlines:
          color: "white"

      hAxis:
        title: "Time"
        gridlines:
          color: "white"
      
      legend:
        position: "none"


    formatters: {}


  $scope.chartRH =
    type: "LineChart"
    displayed: true
    cssStyle: "height:100px; width:100px;"
    data:
      cols: [
        id: "time"
        label: "Time"
        type: "datetime"
      ,
        id: "humidity"
        label: "%"
        type: "number"
      ]
      rows: [
      ]

    options:
      title: ""
      isStacked: "true"
      xfill: 20
      displayExactValues: true
      curveType: "function"
      vAxis:
        title: ""
        minValue: 56
        maxValue: 57
        gridlines:
          color: "white"

      hAxis:
        title: "Time"
        gridlines:
          color: "white"
      legend:
        position: "none"

    formatters: {}
  ]
