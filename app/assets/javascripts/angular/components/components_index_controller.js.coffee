@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  @index = []
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    @index = data
  return this
]
