# This isn't true friction, it just does an animated slide when the rounded itemOffset 
# changes integer, but that seems sufficient for now.

angular.module('ChefStepsApp').directive 'csfrictionslider', ["$window", ($window) ->
  restrict: 'E'
  scope: { itemOffset: "="},
  transclude: true
  template: '<div ng-transclude></div>'

  link: (scope, element, attr) ->
    scope.$watch "itemOffset", (newValue, oldValue) ->
      itemWidth = $(element).children().first().children().first()?.width()
      return if ! itemWidth
      if Math.round(newValue) != Math.round(oldValue)
        $(element).animate({left: - Math.round(newValue) * itemWidth}, 250)


]