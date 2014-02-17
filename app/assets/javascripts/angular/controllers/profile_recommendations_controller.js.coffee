@app.controller 'ProfileRecommendationsController', ["$scope", "$rootScope", "csAuthentication", ($scope, $rootScope, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.refinable = true

  $scope.init = (recommendationType) ->
    $scope.recommendationType = recommendationType

  $scope.open = ->
    if $scope.currentUser.survey_results
      $rootScope.$emit('openRecommendations')
    else
      $rootScope.$emit('openSurvey')

]