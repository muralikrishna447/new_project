angular.module('ChefStepsApp').directive 'cscoursescroll', [ ->
  restrict: 'A'
  link: (scope, element, attrs, CoursesController) ->
    el = angular.element(element)
    scope.oldScrollPosition = 0
    scope.oldShowNav = false
    el.on 'scroll', ->
      console.log 'scrolling'
      newScrollPosition = angular.element(this).scrollTop()
      scrollVelocity = newScrollPosition - scope.oldScrollPosition
      console.log "newScrollPosition: " + newScrollPosition
      threshold = -120
      if scope.showNav
        # When the nav is showing, hide the nav when user scrolls down
        if scrollVelocity > 20
          scope.showNav = false
      else
        # When the nav is hidden, show the nav when the user quick scrolls up
        if scrollVelocity < threshold
          scope.showNav = true
        else
          scope.showNav = false

        # Show the nav if the user reaches the top of the page
        if newScrollPosition <= 0
          scope.showNav = true

      if scope.oldShowNav != scope.showNav
        scope.$emit 'showGlobalNavChanged', scope.showNav
        console.log "SHOW GLOBAL NAV CHANGED TO: " + scope.showNav
      scope.oldScrollPosition = newScrollPosition
      scope.oldShowNav = scope.showNav
]