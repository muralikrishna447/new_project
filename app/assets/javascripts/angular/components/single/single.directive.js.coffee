@components.directive 'singleForm', ['Mapper', 'componentItem', (Mapper, componentItem) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypes = componentItem.types
    scope.component.form.metadata.api = {} unless scope.component.form.metadata.api
    scope.component.form.metadata.custom = {} unless scope.component.form.metadata.custom
    scope.$watch 'component.form.mode', (newValue, oldValue) ->
      apiMode = newValue
      if apiMode && apiMode != oldValue
        switch apiMode
          when 'api'
            console.log 'API MODE'
            scope.component.form.metadata.custom = {}
          when 'custom'
            console.log 'scope.component', scope.component
            metadata = scope.component.form.metadata
            unless Object.keys(metadata.custom).length > 0
              source = metadata.api.source
              mapper = metadata.api.mapper
              metadata.custom = {}
              Mapper.do(source, mapper).then (item) ->
                scope.component.form.metadata.custom.item = item
                scope.component.form.metadata.custom.item.styles = scope.component.form.metadata.api.styles

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
          source = scope.component.metadata.api.source
          mapper = scope.component.metadata.api.mapper
          if source && mapper
            Mapper.do(source, mapper).then (item) ->
              scope.item = item
              scope.item.styles = scope.component.metadata.api.styles
              console.log 'scope.item: ', scope.item
        when 'custom'
          scope.item = scope.component.metadata.custom.item
    ), true

  templateUrl: '/client_views/component_single.html'
]
