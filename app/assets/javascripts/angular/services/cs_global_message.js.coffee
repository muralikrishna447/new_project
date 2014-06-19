angular.module('ChefStepsApp').service 'csGlobalMessage', ['$http', ($http) ->
  settings = {}
  this.getSettings = ->
    $http.get('/settings').then (response) ->
      settings = response.data
    return settings

  this.getSettings()

  this
]
