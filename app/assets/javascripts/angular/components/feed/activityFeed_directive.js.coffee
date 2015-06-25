@components.directive 'activityFeed', ['Mapper', 'componentItemService', '$http', (Mapper, componentItemService, $http) ->
  restrict: 'A'
  scope: {
    component: '='
    columns: '=?'
    rows: '=?'
    itemTypeName: '=?'
    charLimit: '=?'
    buttonMessage: '=?'
    theme: '=?'
  }

  link: (scope, element, attrs) ->
    itemTypeName = scope.itemTypeName ?= scope.component.meta.itemTypeName
    itemType = componentItemService.get(itemTypeName)
    mapper = Mapper.generate(itemType.attrs)
    Mapper.update(mapper, 'buttonMessage', {value: 'See the recipe'})

    scope.getActivities = ->
      $http.get('/api/v0/activities').success (data, status, headers, config) =>
        numItems = scope.rows * scope.columns
        dataToMap = data.slice(0, numItems)
        scope.items = Mapper.mapObject(dataToMap, mapper)

    scope.$watch 'component', (newValue, oldValue) ->
      if newValue
        scope.columns = newValue.meta.columns
        scope.rows = newValue.meta.rows
        scope.itemTypeName = newValue.meta.itemTypeName
        scope.theme = newValue.meta.theme
        scope.buttonMessage = newValue.meta.buttonMessage

    scope.$watch 'columns', (newValue, oldValue) ->
      if newValue
        scope.getActivities()

    scope.$watch 'rows', (newValue, oldValue) ->
      if newValue
        scope.getActivities()

  templateUrl: '/client_views/component_feed.html'
]
