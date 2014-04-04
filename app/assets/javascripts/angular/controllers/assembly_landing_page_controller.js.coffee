@app.controller 'AssemblyLandingPageController', ["$scope", "$rootScope", "$timeout", ($scope, $rootScope, $timeout) ->

  $timeout ->
    mixpanel.track('Course Landing Viewed', 
      _.extend(
        {
          'context': 'course', 
          'title' : $scope.assembly.title
          'slug' : $scope.assembly.slug
        }, $rootScope.splits));
    _gaq.push(['_trackEvent', 'Course', 'Viewed', $scope.assembly.title, null, true]);

]
