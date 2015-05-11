@components = angular.module 'cs.components', []

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
