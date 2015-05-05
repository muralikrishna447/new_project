@componentsManager.controller 'ComponentsNewController', ['$http', ($http) ->
  @component = {}

  @create = (component) ->
    console.log 'Creating Component'
    console.log component
    $http.post('/api/v0/components', {component: component}).success (data, status, headers, config) ->
      console.log 'components data: ', data

  return this
]
