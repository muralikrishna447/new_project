@app.directive 'galleryscroll', ["$window", "$document", ($window, $document) ->
  (scope, element, attr) ->
    window_element = angular.element($window)
    document_element = angular.element($document)
    raw = element[0]
    window_element.scroll(
      _.throttle( (->
        #console.log "#{window_element.scrollTop() + window_element.height()} #{document_element.height() - 200}"
        if window_element.scrollTop() + window_element.height() >= document_element.height() - 200
          scope.$apply(attr.galleryscroll)), 
      250))
]