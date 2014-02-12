@app.controller 'ProfileRecommendationsController', ["$scope", "$resource", "$http", "$modal", "csAuthentication", ($scope, $resource, $http, $modal, csAuthentication) ->
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

  $scope.openSurvey = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_survey.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      resolve:
        afterSubmit: ->
          'showRecommendations'
      controller: 'SurveyModalController'
    )
    mixpanel.track('Survey Opened')

  $scope.open = ->
    if $scope.currentUser.survey_results
      $scope.openRecommendations()
    else
      $scope.openSurvey()

  $scope.$on 'refineRecommendations', (event, data) ->
    $scope.openSurvey()

  $scope.$on 'showRecommendations', ->
    $scope.openRecommendations()
]