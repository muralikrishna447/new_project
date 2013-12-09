angular.module('ChefStepsApp').directive 'csfilepicker', ->
  restrict: 'C',
  replace: true,
  require: '?ngModel',
  scope: true,
  template:
    '<div>' +
      '<div class="btn-toolbar" style="display: inline-block;">' +
        '<button class="btn btn-large btn-primary drop-target relative" ng-click="pickOrRemoveFile()">' +
          '<i class="{{hasFile() && \'icon-remove\' || \'icon-plus\'}}"></i>' +
          '<div class="upload-progress" ng-show="uploadProgress >= 0">' +
            '<progress value="uploadProgress"></progress>' +
          '</div>' +
        '</button>' +
      '</div>' +
    '</div>'

  link: (scope, element, attrs, ngModel) ->
    scope.ngModel = ngModel
    scope.uploadProgress = -1

    target = $(element).find('.drop-target')

    filepicker.makeDropPane target,
      dragEnter: => target.addClass("active")
      dragLeave: => target.removeClass("active")
      onStart: =>
        scope.uploadProgress = 0
        scope.$apply()

      onProgress: (percentage) =>
        scope.uploadProgress = percentage
        scope.$apply()

      onSuccess: (fpfiles) =>
        scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0]))
        target.removeClass("active")
        scope.uploadProgress = -1

      onError: (type, message) ->
        target.removeClass("active")
        scope.uploadProgress = -1
        alert(message)

  controller: ['$scope', '$element', ($scope, $element) ->

    $scope.pickOrRemoveFile = ->
      if $scope.hasFile()
        $scope.removeFile()
      else
        filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"},
        ((fpfiles) =>
          $scope.ngModel.$setViewValue(JSON.stringify(fpfiles[0]))
          $scope.$apply()
        )
        ((errorCode) =>
          console.log("FILEPICKER ERROR CODE: " + errorCode))

    $scope.hasFile = ->
      $scope.ngModel? && $scope.ngModel.$modelValue? && ($scope.ngModel.$modelValue.length > 0)

    $scope.removeFile = ->
      $scope.ngModel.$setViewValue("")
  
  ]