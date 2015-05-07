# Factory that maps to api v0 components endpoint
@components.factory 'Component', ['$resource', ($resource) ->
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

# Directive to load components.  Currently loads with an id or slug
# Todo: Load component by name
@components.directive 'componentLoad', ['Component', (Component) ->
  restrict: 'A'
  scope: {
    componentId: '='
  }

  link: (scope, element, attrs) ->
    Component.show {id: attrs.componentId}, (data) ->
      scope.component = data

  template:
    """
      <div>
        <div hero component='component' ng-if="component.componentType=='hero'"></div>
        <div list component='component' ng-if="component.componentType=='list'"></div>
        <div matrix component='component' ng-if="component.componentType=='matrix'"></div>
      </div>
    """
]

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

@componentsManager.controller 'ComponentsEditController', ['Component', '$stateParams', '$state', (Component, $stateParams, $state) ->
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

  return this
]
