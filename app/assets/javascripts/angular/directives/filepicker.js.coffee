angular.module('ChefStepsApp').directive 'csfilepicker', ->
  restrict: 'C',
  replace: true,
  require: '?ngModel',
  scope: true,
  template: '<div><div class="btn-toolbar" style="display: inline-block;"><input type="button" class="filepicker-pick-button btn btn-small btn-warning" ng-click="pickFile()">Upload</button><button class="btn btn-small btn-warning remove-filepicker-image" ng-click="removeFile()" ng-hide="! hasFile()">Remove</button><button class="btn btn-small" ng-show="picking"><i class="icon-spinner icon-spin"></i></button></div></div>',

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

    $scope.hasFile = ->
      $scope.ngModel.$modelValue? && ($scope.ngModel.$modelValue.length > 0)

    $scope.removeFile = ->
      $scope.ngModel.$setViewValue("")

  ]