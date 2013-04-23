# Angular.js wysiwyg mode stuff. This can't wait til after page load, it needs to happen in the <head>

angular.module('ChefStepsApp', ["ngResource"]).controller 'ActivityController', ($scope) ->
  $scope.activity = {title: "yeah baby"}