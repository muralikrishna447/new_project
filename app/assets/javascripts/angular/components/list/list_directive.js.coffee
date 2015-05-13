@components.directive 'listForm', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.component.content = []
    scope.$watch 'component', ((newValue, oldValue) ->
      # console.log 'newValue: ', newValue
      # console.log 'oldValue: ', oldValue
      if ! scope.component.form.metadata then scope.component.form.metadata = {}
      switch scope.component.form.mode
        when 'api'
          source = scope.component.form.metadata.source
          mapper = scope.component.form.metadata.mapper
          maxitems = scope.component.form.metadata.maxitems
          if source
            $http.get(source).success((data, status, headers, config) ->
              contentData = data
              if maxitems
                scope.component.response = contentData.slice(0, maxitems)
              else
                scope.component.response = contentData
              Mapper.mapArray(mapper, scope.component.content, scope.component.response)
            )
      ), true

  templateUrl: '/client_views/component_list_form.html'
]

@components.directive 'list', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->
    scope.content = []
    scope.$watch 'component', ((newValue, oldValue) ->
      if newValue
        switch scope.component.mode
          when 'api'
            source = scope.component.metadata.source
            mapper = scope.component.metadata.mapper
            maxitems = scope.component.metadata.maxitems
            if source
              $http.get(source).success((data, status, headers, config) ->
                contentData = data
                if maxitems
                  scope.response = contentData.slice(0, maxitems)
                else
                  scope.response = contentData
                Mapper.mapArray(mapper, scope.content, scope.response)
              )
    ), true

  templateUrl: '/client_views/component_list.html'
]
