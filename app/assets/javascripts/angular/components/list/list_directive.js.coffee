@app.directive 'list', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    containerList: '@'
  }
  link: (scope, $element, $attrs) ->
    scope.content = {}
    scope.$watch 'list', (newValue, oldValue) ->
      list = JSON.parse(newValue)
      console.log 'list: ', list
      switch list.mode
        when 'api'
          $http.get(list.source).success((data, status, headers, config) ->
            contentData = data
            if list.maxItems
              contentData = contentData.slice(0, list.maxItems)

            scope.content = contentData
            return
          ).error (data, status, headers, config) ->
            console.log data
            return

  templateUrl: '/client_views/component_list.html'
]