@app.controller 'ProfileRecommendationsController', ["$scope", "$resource", "$http", "$modal", "$rootScope", "csAuthentication", ($scope, $resource, $http, $modal, $rootScope, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()
  $scope.refinable = true

  $scope.init = (recommendationType) ->
    $scope.recommendationType = recommendationType

  $scope.openRecommendations = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_recommendations.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve:
        refinable: ->
          $scope.refinable
        recommendationType: ->
          $scope.recommendationType
      controller: 'RecommendationsModalController'
    )

  $scope.open = ->
    if $scope.currentUser.survey_results
      $scope.openRecommendations()
    else
      $rootScope.$emit('openSurvey')

  $scope.$on 'showRecommendations', ->
    $scope.openRecommendations()
]