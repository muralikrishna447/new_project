@components.directive 'heroForm', ['Mapper', 'componentItem', (Mapper, componentItem) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypes = componentItem.types

    scope.$watch 'component.form.mode', (newValue, oldValue) ->
      apiMode = newValue
      if apiMode
        switch apiMode
          when 'api'
            console.log 'API MODE'
          when 'custom'
            console.log 'scope.component', scope.component
            Mapper.do(scope.component.form.metadata.source, scope.component.form.metadata.mapper).then (item) ->
              scope.component.form.metadata.item = item

  templateUrl: '/client_views/component_hero_form.html'
]

@components.directive 'hero', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      switch scope.component.mode
        when 'api'
          console.log 'API HIT'
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          if source && mapper
            Mapper.do(source, mapper).then (item) ->
              scope.item = item
              console.log 'scope.item: ', scope.item
        when 'custom'
          scope.item = scope.component.metadata.item
    ), true

  templateUrl: '/client_views/component_hero.html'
]
