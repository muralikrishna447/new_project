@components.directive 'heroForm', ['Mapper', (Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.itemTypeOptions = [
      {
        name: 'Square A'
        className: 'square.square-a'
        attrs: ['title', 'image', 'buttonMessage', 'url']
        templateUrl: 'component_matrix_item_square_a.html'
        formTemplateUrl: 'component_matrix_item_square_a_form.html'
      }
      {
        name: 'Circle'
        attrs: ['title', 'image', 'buttonMessage', 'url']
      }
    ]

    scope.$watch 'component.form.mode', (newValue, oldValue) ->
      apiMode = newValue
      if apiMode
        switch apiMode
          when 'api'
            console.log 'API MODE'
          when 'custom'
            console.log 'scope.component', scope.component
            Mapper.do(scope.component.form.metadata.source, scope.component.form.metadata.mapper).then (content) ->
              scope.component.form.metadata.item = content

    scope.getTemplate = (templateUrl) ->
      return '/client_views/' + templateUrl

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
          source = scope.component.metadata.source
          mapper = scope.component.metadata.mapper
          if source && mapper
            Mapper.do(source, mapper).then (item) ->
              scope.item = item
        when 'custom'
          scope.item = scope.component.metadata.item
    ), true

    scope.getTemplate = (templateUrl) ->
      return '/client_views/' + templateUrl

  templateUrl: '/client_views/component_hero.html'
]
