angular.module('ChefStepsApp').directive 'csfilepicker', ->
  restrict: 'C',
  replace: true,
  require: '?ngModel',
  template: '<div><div class="btn-toolbar" style="display: inline-block;"><button class="filepicker-pick-button btn btn-small btn-warning" ng-click="pickFile()">Upload Image</button><button class="btn btn-small btn-warning remove-filepicker-image" ng-click="removeFile()" ng-hide="activity.image_id.length == 0">Remove Image</button><button class="btn btn-small" ng-show="picking"><i class="icon-spinner icon-spin"></i></button></div></div>',

  link: (scope, element, attrs, ngModel) ->
    scope.ngModel = ngModel
    scope.picking = false

  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.pickFile = ->
      $scope.picking = true
      filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"},
      ((fpfiles) =>
        $scope.picking = false
        $scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0]))
        $scope.$apply()
      )
      ((errorCode) =>
        $scope.picking = false
        console.log("FILEPICKER ERROR CODE: " + errorCode))

    $scope.removeFile = ->
      $scope.activity.image_id = ""

  ]