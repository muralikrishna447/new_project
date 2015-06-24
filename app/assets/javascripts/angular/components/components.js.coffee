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
  this
]

# Directive to load components.  Currently loads with an id or slug
# Todo: Load component by name
@components.directive 'componentLoad', ['Component', 'csAuthentication', (Component, csAuthentication) ->
  restrict: 'A'
  scope: {}

  link: (scope, element, attrs) ->
    scope.componentId = attrs.componentId
    Component.show {id: attrs.componentId}, (data) ->
      scope.component = data

    scope.showEditButton = false
    scope.showEdit = ->
      scope.showEditButton = true if csAuthentication.isAdmin()

    scope.hideEdit = ->
      scope.showEditButton = false


  template:
    """
      <div class='component' ng-class="component.meta.size" ng-switch="component.componentType" ng-mouseenter='showEdit()' ng-mouseleave='hideEdit()'>
        <a class='component-edit-button' ng-if='showEditButton' ng-href="/components/{{component.slug}}/edit" target='_blank'>
          <i class='fa fa-edit'> Edit</i>
        </a>
        <div search-feed component='component' ng-switch-when="feed" char-limit="component.meta.descriptionCharLimit"></div>
        <div matrix component='component' ng-switch-when="matrix"></div>
        <div madlib component='component' ng-switch-when="madlib"></div>
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
@components.service 'Mapper', [ ->

  @mapObject = (data, connections, maxNumber) ->
    if maxNumber
      data = data.splice(0, maxNumber)

    responseKeys = Object.keys(data)

    mapped = data.map (item, index) ->
      mappedItem = {}
      for connection in connections
        value = connection.value
        if value && connection.value.length > 0
          mappedItem[connection.componentKey] = value
        else
          mappedItem[connection.componentKey] = item[connection.sourceKey]
      return { content: mappedItem }

  # Generates a mapper object from an array of attrs
  @generate = (attrs) ->
    mapper = []
    for attr in attrs
      mapperItem =
        componentKey: attr
        sourceKey: attr
        value: ""
      mapper.push mapperItem
    return mapper

  # Updated an item in a mapper object
  # Example 1: Mapper.update(mapper, 'buttonMessage', {value: 'See the recipe'})
  # Example 2: Mapper.update(mapper, 'buttonMessage', {sourceKey: 'title'})
  @update = (mapper, componentKey, updateObject) ->
    for mapperItem in mapper
      if mapperItem['componentKey'] == componentKey
        angular.forEach updateObject, (value, key) ->
          mapperItem[key] = value

  return this
]

@components.directive 'filepicker', [->
  restrict: 'A'
  require: '?ngModel'
  link: (scope, element, attrs, ngModel) ->
    scope.pick = ->
      filepicker.pick (blob) ->
        url = blob.url.replace('https://www.filepicker.io', 'https://d3awvtnmmsvyot.cloudfront.net')
        ngModel.$setViewValue(url)
        scope.$apply()
  template:
    """
      <button class='btn btn-secondary' ng-click='pick()'>Pick Image</btn>
    """
]

@components.directive 'lineClamp', ['$timeout', ($timeout) ->
  restrict: 'A'
  scope: {
    lineClamp: '='
  }
  link: (scope, element, attrs) ->

    getNumLines = ->
      elementHeight = element[0].clientHeight
      lineHeight = parseInt(getComputedStyle(element[0]).getPropertyValue('line-height'))
      numLines = elementHeight/lineHeight
      return numLines

    $timeout ->

      console.log 'num lines: ', getNumLines()
      console.log 'line clamp: ', parseInt(scope.lineClamp)
      while getNumLines() > parseInt(scope.lineClamp)
        text = element.text()
        lastIndex = text.lastIndexOf(" ")
        text = text.substring(0, lastIndex)
        element.text(text)

      text = element.text()
      lastIndex = text.lastIndexOf(" ")
      text = text.substring(0, lastIndex)

      element.text(text + '...')

]
