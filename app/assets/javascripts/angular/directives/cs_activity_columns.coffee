@app.directive 'csActivityColumns', ["$window", ($window) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    updateColumns = ->
      oldColumns = scope.activityColumns
      oldNoInsets = scope.noInsets

      width = $(element).width() 

      # Note these numbers relate to $desktop-standard-item-width etc; not sure how to share
      # them with css :(. 
      scope.activityColumns = 3
      scope.activityColumns = 2 if width < 1266
      scope.activityColumns = 1 if width < 990
      element.removeClass('activity-columns-1 activity-columns-2 activity-columns-3')
      element.addClass("activity-columns-#{scope.activityColumns}")

      scope.noInsets = (window.innerWidth < 768)
      console.log("#{scope.activityColumns} #{scope.noInsets}")

      if ((oldColumns != scope.activityColumns) || (oldNoInsets != scope.noInsets))
        scope.$apply() if (! scope.$$phase)
      else

    # Watch the element for direct resizing
    scope.$watch (-> $(element).width()), updateColumns 

    # Watch the window
    angular.element($window).on 'resize', updateColumns

]