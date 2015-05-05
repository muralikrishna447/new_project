@componentsManager.controller 'ComponentsController', ['$http', ($http) ->
  console.log 'Components Controller Loaded'
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    console.log 'components data: ', data
]
