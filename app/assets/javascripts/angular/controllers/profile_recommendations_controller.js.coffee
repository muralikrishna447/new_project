@app.controller 'ProfileRecommendationsModalController', ["$scope", "$modal", ($scope, $modal) ->

  $scope.open = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_profile_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      controller: 'ProfileRecommendationsController'
    )

]

@app.controller 'ProfileRecommendationsController', ["$scope", "$rootScope", "csAuthentication", '$modalInstance', ($scope, $rootScope, csAuthentication, $modalInstance) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.refinable = true
  $scope.showSurvey = false
  $scope.showRecommendations = true

  $scope.refine = ->
    $scope.showSurvey = true
    $scope.showRecommendations = false
    mixpanel.track('Recommendations Refine Button Clicked')

  $scope.saveSurvey = ->
    $scope.showSurvey = false
    $scope.showRecommendations = true
    $rootScope.$emit 'closeSurveyFromFtue'

  $scope.close = ->
    $modalInstance.close()

]