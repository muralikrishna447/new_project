angular.module('ChefStepsApp').controller 'UploadsController', ["$scope", "$resource", "$http", "$rootScope", ($scope, $resource, $http, $rootScope) ->

  $scope.upload = {}
  $scope.upload.image_src = {}
  $scope.upload.assembly_id = {}
  $scope.upload.status = 'new'
  $scope.upload.path = {}

  $scope.init = (assembly_id) ->
    $scope.upload.assembly_id = assembly_id

  $scope.addPhoto = (upload) ->
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3", path: '/users_uploads/'}, (fpfiles) =>
      fpfile = JSON.stringify(fpfiles[0])
      $scope.upload.image_id = fpfile
      $scope.photoPreview(fpfile)
      $scope.$apply()

  $scope.submit = () ->
    $http({
      url: '/uploads.js',
      method: 'POST',
      data: this.upload
    }).success((data, status) ->
      $scope.upload.status = 'show'
      $scope.shareModalShow = 'true'
      $scope.upload.path = data.path
      console.log data
      $rootScope.$broadcast('socialURLUpdated', 'http://www.chefsteps.com' + data.path)
    )

  $scope.photoPreview = (file) ->
    width = 300
    url = JSON.parse(file).url
    src = [url , "/convert?fit=max&w=", width, "&h=", Math.floor(width * 16.0 / 9.0)].join("")
    $scope.upload.image_src = src

  $scope.hideShareModal = () ->
    $scope.shareModalShow = false
  
]