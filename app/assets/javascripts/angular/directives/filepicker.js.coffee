angular.module('ChefStepsApp').directive 'csfilepicker', ->
  restrict: 'C',
  replace: true,
  require: '?ngModel',
  scope: true,
  template:
    '<div>' +
      '<div class="btn-toolbar" style="display: inline-block;">' +
        '<div class="drop-target relative" ng-click="pickOrRemoveFile()" >' +
          '<span ng-show="uploadProgress < 0" class="{{hasFile() && \'icon-remove\' || \'icon-plus\'}}"></span>' +
          '<div class="upload-progress" ng-show="uploadProgress >= 0">' +
            '{{uploadProgress}}%' +
          '</div>' +
        '</div>' +
      '</div>' +
    '</div>'

  link: (scope, element, attrs, ngModel) ->
    scope.ngModel = ngModel
    scope.uploadProgress = -1

    target = $(element).find('.drop-target')

    filepicker.makeDropPane target,
      dragEnter: => target.addClass("drop-ready")
      dragLeave: => target.removeClass("drop-ready")
      onStart: =>
        scope.uploadProgress = 0
        target.removeClass("drop-ready")
        scope.$apply() if ! scope.$$phase

      onProgress: (percentage) =>
        scope.uploadProgress = percentage
        scope.$apply() if ! scope.$$phase

      onSuccess: (fpfiles) =>
        scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0]))
        scope.uploadProgress = -1
        scope.$apply() if ! scope.$$phase

      onError: (type, message) ->
        scope.uploadProgress = -1
        alert(message)
        scope.$apply() if ! scope.$$phase

  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.pickOrRemoveFile = ->
      if $scope.hasFile()
        $scope.removeFile()
      else
        filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"},
        ((fpfiles) =>
          $scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0]))
          $scope.$apply() if ! $scope.$$phase
        )
        ((errorCode) =>
          console.log("FILEPICKER ERROR CODE: " + errorCode))

    $scope.hasFile = ->
      $scope.ngModel? && $scope.ngModel.$modelValue? && ($scope.ngModel.$modelValue.length > 0)

    $scope.removeFile = ->
      $scope.ngModel.$setViewValue("")
      $scope.$apply() if ! $scope.$$phase
  
  ]
