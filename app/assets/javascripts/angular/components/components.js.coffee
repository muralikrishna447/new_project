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

]

# Directive to load components.  Currently loads with an id or slug
# Todo: Load component by name
@components.directive 'componentLoad', ['Component', (Component) ->
  restrict: 'A'
  scope: {
    showEdit: '='
  }

  link: (scope, element, attrs) ->
    scope.componentId = attrs.componentId
    Component.show {id: attrs.componentId}, (data) ->
      scope.component = data
      scope.editLink = "/components/#{scope.componentId}/edit"
    , (error) ->
      if error.status == 404
        console.log 'Try Adding a New COmponent'

  template:
    """
      <div>
        <a class='btn btn-secondary' ng-if='showEdit' ng-href='{{editLink}}' target='_blank'>Edit {{componentId}}</a>
        <div hero component='component' ng-if="component.componentType=='hero'"></div>
        <div list component='component' ng-if="component.componentType=='list'"></div>
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

  @mapOne = (mapper, content, source) ->
    angular.forEach mapper, (sourceKey, contentKey) ->
      content[contentKey] = source[sourceKey]

  @mapArray = (mapper, content, source) ->
    source.map (item, index) ->
      angular.forEach mapper, (sourceKey, contentKey) ->
        if typeof content[index] == 'undefined'
          content[index] = {}
        content[index][contentKey] = item[sourceKey]

  # source is a url to an API endpoint
  # componentKeys is an array containing the keys to map to
  @do = (sourceUrl, connections) ->
    deferred = $q.defer()
    if sourceUrl
      mapped = []
      $http.get(sourceUrl).success (data, status, headers, config) ->
        if data.length > 1
          responseKeys = Object.keys(data[0])
        else
          responseKeys = Object.keys(data)

        mapped = data.map (item) ->
          mappedItem = {}
          for connection in connections
            value = connection.value
            if value && connection.value.length > 0
              mappedItem[connection.componentKey] = value
            else
              mappedItem[connection.componentKey] = item[connection.sourceKey]
          return mappedItem

        deferred.resolve mapped

    return deferred.promise

  return this
]
