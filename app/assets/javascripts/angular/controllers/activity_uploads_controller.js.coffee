angular.module('ChefStepsApp').controller 'ActivityUploadsController' , ["$scope", "$resource", "$http", "$rootScope", ($scope, $resource, $http, $rootScope) ->
  
  $scope.upload = {}
  $scope.upload.likes_count = 0

  $scope.init = (upload_id, likes_count) ->
    $scope.upload.id = upload_id
    $scope.upload.likes_count = likes_count

  $scope.getObject = ->
    $scope.upload

  $scope.getObjectTypeName = ->
    "Upload"

  $scope.socialURL = () ->
    'http://www.chefsteps.com/bleh'

]