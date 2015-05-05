@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  console.log 'Components Index Controller Loaded'
  $http.get('/api/v0/components').success (data, status, headers, config) ->
    console.log 'components data: ', data
]
