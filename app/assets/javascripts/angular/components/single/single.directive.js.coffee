@components.directive 'singleForm', ['Mapper', 'componentItem', (Mapper, componentItem) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypes = componentItem.types

    scope.$watch 'component.form.mode', (newValue, oldValue) ->
      apiMode = newValue
      if apiMode && apiMode != oldValue
        switch apiMode
          when 'api'
            console.log 'API MODE'
          when 'custom'
            console.log 'scope.component', scope.component
            Mapper.do(scope.component.form.metadata.source, scope.component.form.metadata.mapper).then (item) ->
              scope.component.form.metadata.item = item
              scope.component.form.metadata.item.styles = scope.component.form.metadata.styles

  templateUrl: '/client_views/component_single_form.html'
]

@components.directive 'single', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.$watch 'component', ((newValue, oldValue) ->
      switch scope.component.mode
        when 'api'
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          if source && mapper
            Mapper.do(source, mapper).then (item) ->
              scope.item = item
              scope.item.styles = scope.component.metadata.styles
              console.log 'scope.item: ', scope.item
        when 'custom'
          scope.item = scope.component.metadata.item
    ), true

  templateUrl: '/client_views/component_single.html'
]
