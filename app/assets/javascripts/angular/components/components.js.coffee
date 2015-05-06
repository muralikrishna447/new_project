@componentsManager.factory 'Component', ['$resource', ($resource) ->
  $resource '/api/v0/components/:id', { id: '@id' },
    'create':
      method: 'POST'
    'index':
      method: 'GET'
      isArray: true
    'show':
      method: 'GET'
      isArray: false
    'update':
      method: 'PUT'
    'destroy':
      method: 'DELETE'
]

@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  @index = []
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    @index = data
  return this
]

@componentsManager.controller 'ComponentsNewController', ['$http', ($http) ->
  @component = {}

  @create = (component) ->
    console.log 'Creating Component'
    console.log component
    $http.post('/api/v0/components', {component: component}).success (data, status, headers, config) ->
      console.log 'components data: ', data

  return this
]

@componentsManager.controller 'ComponentsEditController', ['Component', '$stateParams', '$state', (Component, $stateParams, $state) ->

  Component.show {id: $stateParams.id}, (component) =>
    @form = component

  @save = (component) ->
    componentParams = component
    delete componentParams['id']
    delete componentParams['slug']
    Component.update {id: $stateParams.id, component: componentParams}, (component) ->
      $state.go('components.index')

  return this
]
