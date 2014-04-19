@app.directive 'csFetch', ["$injector", ($injector) ->
  restrict: 'A'
  scope: { part: "@"},
  replace: 'true'
  template: '<div ng-bind-html="fetched"></div>'

  link: (scope, element, attrs) ->
    loading = '''
      <h4 class='fetch-content-loading'>Loading...</h4>
    '''

    scope.fetched = loading

    scope.reload = ->
      $injector.invoke([attrs.type, (resourceObject) ->
        resourceObject.get_as_json(
          {id: attrs.csFetch}
          (value) ->
            scope.obj = value
            if attrs.part?
              scope.fetched = scope.obj[attrs.part] || scope.obj.text_fields?[attrs.part] || ("<span style='color: red;'>ERROR: couldn't find section named '" + attrs.part + "'</span>")
          (error) ->
            error.data = "couldn't find #{attrs.type} with slug '#{attrs.csFetch}'" if error.status == 404
            scope.fetched = "<span style='color: red;'>ERROR (#{error.status}): #{error.data}</span>"
        )
      ])

    scope.$watch attrs.csFetch,  ->
      scope.reload()
]