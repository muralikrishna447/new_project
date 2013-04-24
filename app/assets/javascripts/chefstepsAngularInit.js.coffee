# Angular.js wysiwyg mode stuff. This can't wait til after page load, it needs to happen in the <head>

angular.module('ChefStepsApp', ["ngResource"]).controller 'ActivityController', ($scope, $resource) ->
  Activity = $resource("/activities/:id", {id:  $('#activity-body').data("activity-id")})
  $scope.activity = Activity.get()