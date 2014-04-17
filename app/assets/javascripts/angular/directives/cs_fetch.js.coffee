@app.directive 'csFetch', ["Ingredient", (Ingredient) ->
  restrict: 'A'
  scope: { part: "="},
  transclude: true
  template: '<div cs-contenteditable="false" ng-model="fetched"></div>'

  link: (scope, element, attrs) ->
    scope.reload = ->
      eval(attrs.type).get_as_json(
        {id: attrs.csFetch}, 
        (value) ->
          scope.object = value
          scope.fetched = scope.object.attrs.part || scope.object.text_fields[scope.object.attrs.part]
      ) 

    scope.$watch attrs,  ->
      scope.reload()
]