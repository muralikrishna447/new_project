angular.module('ChefStepsApp').directive 'cscoursescroll', [ ->
  restrict: 'A'
  link: (scope, element, attrs, CoursesController) ->
    el = angular.element(element)
    scope.oldScrollPosition = 0
    scope.oldShowNav = false
    scope.oldShowBottom = false
    scope.height = el.height()
    scope.window_height = angular.element(window).height()

    el.on 'scroll', ->
      newScrollPosition = angular.element(this).scrollTop()
      scrollVelocity = newScrollPosition - scope.oldScrollPosition
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
      scope.oldScrollPosition = newScrollPosition
      scope.oldShowNav = scope.showNav

      # Show bottom if user reaches bottom
      if newScrollPosition >= (el[0].scrollHeight - scope.height - 125)
        scope.showBottom = true
      else
        scope.showBottom = false

      if scope.oldShowBottom != scope.showBottom
        scope.$emit 'showBottomChanged', scope.showBottom
      scope.oldShowBottom = scope.showBottom

    scope.$on 'scrollToTop', ->
      el.scrollTop 0

]