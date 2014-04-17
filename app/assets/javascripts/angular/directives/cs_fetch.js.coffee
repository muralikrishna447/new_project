@app.directive 'csFetch', ["$injector", ($injector) ->
  restrict: 'A'
  scope: { part: "@"},
  transclude: true
  template: '<div cs-contenteditable="false" ng-model="fetched"></div>'

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
            scope.object = value
            scope.fetched = scope.object[attrs.part] || scope.object.text_fields?[attrs.part] || ("ERROR: couldn't find section named '" + attrs.part + "'")
          (error) ->
            error.data = "couldn't find #{attrs.type} with slug '#{attrs.csFetch}'" if error.status == 404
            scope.fetched = "ERROR (#{error.status}): #{error.data}"
        )
      ])

    scope.$watch attrs,  ->
      scope.reload()
]