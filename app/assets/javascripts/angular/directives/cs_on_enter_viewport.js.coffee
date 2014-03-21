@app.directive 'csOnEnterViewport', ["$window", "$timeout", ($window, $timeout) ->
  restrict: 'A'
  scope:
    reachedScreenCallback: '&'
    offset: "="

  link: (scope, element, attrs) ->
    
    scope.sentCallback = false

    windowElement = angular.element($window)
    windowElement.on 'scroll', (event) ->

      if scope.reachedScreenCallback && ! scope.sentCallback 
        elementPosition = element[0].getBoundingClientRect().top
       
        windowHeight = windowElement.height()
        console.log elementPosition
        console.log windowHeight

        offset = parseInt(scope.offset || 100)

        if (elementPosition < windowHeight - offset)
          console.log "Sending callback"
          $timeout ->
            scope.reachedScreenCallback() 
            scope.sentCallback = true
          
]