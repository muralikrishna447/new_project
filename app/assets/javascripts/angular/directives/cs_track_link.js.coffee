@app.directive 'csTrackLink',  ["$rootScope", ($rootScope) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'click', ->
      mixpanel.track(attrs.csTrackLink, _.extend({url: attrs.href}, $rootScope.splits))
      true

]

