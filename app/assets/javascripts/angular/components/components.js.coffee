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
          # console.log 'Here is an Item: ', item
          mappedItem = {}
          angular.forEach connections, (sourceKey, contentKey) ->
            mappedItem[contentKey] = item[sourceKey]
          return mappedItem
          
        deferred.resolve mapped

    return deferred.promise

  return this
]
