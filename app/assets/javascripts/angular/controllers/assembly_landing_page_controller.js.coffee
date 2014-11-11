@app.controller 'AssemblyLandingPageController', ["$scope", "$rootScope", "$timeout", ($scope, $rootScope, $timeout) ->

  $timeout ->
    eventData = 
      'context': 'course', 
      'title' : $scope.assembly.title
      'slug' : $scope.assembly.slug

    mixpanel.track('Course Landing Viewed', 
      _.extend(eventData, $rootScope.splits));
    _gaq.push(['_trackEvent', 'Course', 'Viewed', $scope.assembly.title, null, true]);
    Intercom('trackEvent', 'course-landing-viewed', eventData)

]
