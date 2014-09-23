angular.module('ChefStepsApp').directive 'csHeroScroll', ["$window", ($window) ->
  restrict: 'A'

  link: (scope, element, attrs) ->
    windowElement = angular.element($window)

    handler = =>
      scrollPosition = windowElement.scrollTop()
      $(element).toggleClass('scrolled', scrollPosition > 0)

    $(window).scroll _.throttle(handler, 200)

]