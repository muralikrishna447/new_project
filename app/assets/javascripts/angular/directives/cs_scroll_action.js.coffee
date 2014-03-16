angular.module('ChefStepsApp').directive 'csScrollAction', ["$window", ($window) ->
  restrict: 'A'
  scope:
    onAppearClass: '@'
    onAppearCallback: '&'
  link: (scope, element, attrs) ->
    elementPosition = element[0].getBoundingClientRect().top
    elementHeight = angular.element(element).height()
    # console.log "element Height", elementHeight
    windowElement = angular.element($window)
    windowHeight = windowElement.height()
    startPosition = elementPosition - 0.5*windowHeight
    endPosition = elementPosition + 2*elementHeight
    # console.log 'Start Position', startPosition
    # console.log 'End Position', endPosition

    sentCallback = false

    windowElement.on 'scroll', (event) ->
      scrollPosition = windowElement.scrollTop()

      if scope.onAppearCallback && ! sentCallback && startPosition < scrollPosition
        scope.onAppearCallback() 
        sentCallback = true
      # console.log scrollPosition
      if startPosition < scrollPosition < endPosition
        element.addClass(scope.onAppearClass)
      else
        element.removeClass(scope.onAppearClass)
]