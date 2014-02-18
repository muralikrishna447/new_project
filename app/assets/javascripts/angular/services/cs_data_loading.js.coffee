angular.module('ChefStepsApp').service 'csDataLoading', [ "$rootScope", ($rootScope) ->
  dataLoading = 0 #This is an integer so we can nest loadings
  fullScreen = false

  this.start = ->
    dataLoading += 1
  this.stop = ->
    dataLoading -= 1
  this.stopAll = ->
    dataLoading = 0
  this.isLoading = ->
    (dataLoading > 0)
  this.loading = ->
    dataLoading
  this.isFullScreen = ->
    fullScreen
  this.willBeFullScreen = (fullScreenValue) ->
    fullScreen = fullScreenValue

  this
]