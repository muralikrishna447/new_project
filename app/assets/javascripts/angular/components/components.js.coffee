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

# Controller to control components.  Mostly if an edit button should be displayed for admins
@components.controller 'homeController', ['csAuthentication', (csAuthentication) ->
  @editable = csAuthentication.isAdmin()
  @showEditable = false
]

@components.directive 'componentEditButton', ['Component', (Component) ->
  restrict: 'E'
  scope: {}

  link: (scope, element, attrs) ->
    scope.componentName = attrs.componentName
    slug = attrs.componentName.split(' ').map((a) ->
        a.toLowerCase()
      ).join('-')

    Component.show {id: slug}, (data) ->
      scope.component = data
      scope.actionName = 'Edit Component:'
      scope.actionUrl = "/components/#{slug}/edit"
    , (error) ->
      if error.status == 404
        scope.actionName = 'Create Component:'
        scope.actionUrl = "/components/new?name=#{scope.componentName}"

  template:
    """
      <div class='component-edit-button'>
        <a class='btn btn-secondary' ng-href='{{actionUrl}}' target='_blank'>{{actionName}} {{componentName}}</a>
      </div>
    """
]

# Directive to load components.  Currently loads with an id or slug
# Todo: Load component by name
@components.directive 'componentLoad', ['Component', (Component) ->
  restrict: 'A'
  scope: {}

  link: (scope, element, attrs) ->
    scope.componentId = attrs.componentId
    Component.show {id: attrs.componentId}, (data) ->
      scope.component = data

  template:
    """
      <div class='component' ng-class="'component-padding-' + component.metadata.allModes.styles.component.padding">
        <div single component='component' ng-if="component.componentType=='single'"></div>
        <div matrix component='component' ng-if="component.componentType=='matrix'"></div>
      </div>
    """
]

# Service to map api response data to component attributes.
# Uses a mapper hash.  Example:
# mapper = {
#   title: 'title'
#   description: 'description'
#   url: 'url'
# }
@components.service 'Mapper', ['$http', '$q', ($http, $q) ->

  @do = (sourceUrl, connections) ->
    deferred = $q.defer()
    if sourceUrl
      mapped = []
      $http.get(sourceUrl).success (data, status, headers, config) ->
        if data.length
          responseKeys = Object.keys(data)

          mapped = data.map (item) ->
            mappedItem = {}
            for connection in connections
              value = connection.value
              if value && connection.value.length > 0
                mappedItem[connection.componentKey] = value
              else
                mappedItem[connection.componentKey] = item[connection.sourceKey]
            return { content: mappedItem }

        else
          responseKeys = Object.keys(data)
          mappedItem = {}
          item = data
          for connection in connections
            value = connection.value
            if value && value.length > 0
              mappedItem[connection.componentKey] = value
            else
              mappedItem[connection.componentKey] = item[connection.sourceKey]
          mapped = { content: mappedItem }

        deferred.resolve mapped

    return deferred.promise

  return this
]
