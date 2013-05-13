angular.module('ChefStepsApp').directive 'csfilepicker', ->
  restrict: 'C',
  replace: true,
  require: '?ngModel',
  template: '<div class="btn-toolbar"><button class="filepicker-pick-button btn btn-small btn-warning" ng-click="pickFile()">Upload Image</button><button class="btn btn-small btn-warning remove-filepicker-image" ng-click="removeFile()" ng-hide="activity.image_id.length == 0">Remove Image</button></div>',

  link: (scope, element, attrs, ngModel) ->
    scope.ngModel = ngModel

  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.pickFile = ->
      filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"},
      ((fpfiles) =>
        $scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0])))
      ((errorCode) =>
        console.log("FILEPICKER ERROR CODE: " + errorCode))

    $scope.removeFile = ->
      $scope.activity.image_id = ""

  ]