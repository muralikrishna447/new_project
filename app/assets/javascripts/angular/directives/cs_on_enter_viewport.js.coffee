@app.directive 'csOnEnterViewport', ["$window", ($window) ->
  restrict: 'A'
  scope:
    reachedScreenCallback: '&'

  link: (scope, element, attrs) ->
    
    scope.sentCallback = false

    windowElement = angular.element($window)
    windowElement.on 'scroll', (event) ->

      if scope.reachedScreenCallback # && ! scope.sentCallback 
        elementPosition = element[0].getBoundingClientRect().top
       
        windowHeight = windowElement.height()
        console.log elementPosition
        console.log windowHeight

        if (elementPosition < windowHeight - 100)
          console.log "Sending callback"
          scope.reachedScreenCallback() 
          scope.sentCallback = true

]