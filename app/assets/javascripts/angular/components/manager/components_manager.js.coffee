@componentsManager.controller 'ComponentsIndexController', ['$http', ($http) ->
  @index = []
  $http.get('/api/v0/components').success (data, status, headers, config) =>
    @index = data
  return this
]

@componentsManager.controller 'ComponentsNewController', ['$http', '$state', ($http, $state) ->
  @componentTypeOptions = ['hero', 'list', 'matrix']
  @component = {}

  @save = (component) ->
    $http.post('/api/v0/components', {component: component}).success (data, status, headers, config) ->
      $state.go('components.index')

  return this
]

@componentsManager.controller 'ComponentsEditController', ['Component', '$stateParams', '$state', 'notificationService', (Component, $stateParams, $state, notificationService) ->
  @componentTypeOptions = ['hero', 'list', 'matrix']
  @colorOptions = ['white', 'black']

  Component.show {id: $stateParams.id}, (component) =>
    @form = component

  @save = (component) ->
    componentParams = component
    delete componentParams['id']
    delete componentParams['slug']
    Component.update {id: $stateParams.id, component: componentParams}, (component) ->
      $state.go('components.index')
      console.log 'component: ', component
      message = "The #{component.name } component was successfully saved. "
      buttonUrl = "/components/#{component.id}/edit"
      buttonText = "Edit #{component.name}"
      notificationService.add('success', message, buttonUrl, buttonText)

  return this
]
