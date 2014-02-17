angular.module('ChefStepsApp').service 'csDataLoading', [ "$rootScope", ($rootScope) ->
  dataLoading = 0 #This is an integer so we can nest loadings

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

  this
]