@app.directive 'csTrackLink',  ["$rootScope", ($rootScope) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'click', ->
      true

]

