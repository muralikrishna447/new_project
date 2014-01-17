angular.module('ChefStepsApp').directive 'csfrictionslider', ["$window", ($window) ->
  restrict: 'e'
  scope: { xx: "=", yy: "="},
  transclude: true

  link: (scope, element, attr) ->
    scope.$watch "xx", (value) ->
      $(element).attr('left', value * attr.itemWidth)


]