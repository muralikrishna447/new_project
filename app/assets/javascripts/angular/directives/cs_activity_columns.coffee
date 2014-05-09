@app.directive 'csActivityColumns', ["$window", ($window) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    updateColumns = ->
      oldColumns = scope.activityColumns
      scope.activityColumns = 3
      width = $(element).width() 
      # Note these numbers relate to $desktop-standard-item-width etc; not sure how to share
      # them with css :(. 
      scope.activityColumns = 2 if width < 1266
      scope.activityColumns = 1 if width < 933
      element.removeClass('activity-columns-1 activity-columns-2 activity-columns-3')
      element.addClass("activity-columns-#{scope.activityColumns}")
      scope.$apply() if (! scope.$$phase) && (oldColumns != scope.activityColumns)

    # Watch the element for direct resizing
    scope.$watch (-> $(element).width()), updateColumns 

    # Watch the window
    angular.element($window).on 'resize', updateColumns

]