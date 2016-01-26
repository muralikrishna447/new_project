angular.module('ChefStepsApp').controller 'ActivityUploadsController' , ["$scope", "$resource", "$http", "$rootScope", "csAlertService", "csConfig", ($scope, $resource, $http, $rootScope, csAlertService, csConfig) ->

  $scope.upload = {}
  $scope.upload.likes_count = 0
  $scope.csAlertService = csAlertService

  $scope.init = (upload_id, likes_count) ->
    $scope.upload.id = upload_id
    $scope.upload.likes_count = likes_count

    $http.get("#{csConfig.bloom.api_endpoint}/discussions/upload_#{$scope.upload.id}?apiKey=xchefsteps").success((data, status) ->
        $scope.commentCount = data["commentCount"]
    )

  $scope.getObject = ->
    $scope.upload

  $scope.getObjectTypeName = ->
    "Upload"

  $scope.socialURL = () ->
    "https://www.chefsteps.com/uploads/" + $scope.upload?.slug

]
