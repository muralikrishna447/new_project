@app.directive 'galleryscroll', ["$window", ($window) ->
  (scope, element, attr) ->
    window_element = angular.element($window)
    raw = element[0]
    window_element.scroll(
      _.throttle( (->
        # console.log(element.height() - window.innerHeight)
        # console.log(window_element.scrollTop())
        if window_element.scrollTop() >= (element.height() - window.innerHeight)
          scope.$apply(attr.galleryscroll)), 
      250, trailing: false))
]