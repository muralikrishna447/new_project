# This isn't true friction, it just does an animated slide when the rounded itemOffset 
# changes integer, but that seems sufficient for now.

angular.module('ChefStepsApp').directive 'csfrictionslider', ["$window", ($window) ->
  restrict: 'E'
  scope: { itemOffset: "=", itemWidth: "="},
  transclude: true
  template: '<div ng-transclude></div>'

  link: (scope, element, attr) ->
    itemWidth = attr.itemWidth

    scope.$watch "itemOffset", (newValue, oldValue) ->
      # not reliable with a repeat, child might not be there yet
      #itemWidth = $(element).children().first().children().first()?.width()

      newRounded = Math.round(newValue)
      oldRounded= Math.round(oldValue)
      newPos = - newRounded * itemWidth
      
      if (! oldValue) || (oldValue == newValue)
        # This is just for (re)initializing when (re)added to dom
        console.log("Jump to #{newPos}")
        $(element).css("left", newPos)

      else if (oldRounded != newRounded)
        $(element).finish()
        console.log "Animate to: #{Math.round(newRounded)} "
        $(element).animate({left: newPos}, 250)


]