angular.module('ChefStepsApp').controller 'UploadsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->

  $scope.upload = {}
  $scope.upload.image_src = {}
  $scope.upload.assembly_id = {}

  $scope.init = (assembly_id) ->
    $scope.upload.assembly_id = assembly_id

  $scope.addPhoto = (upload) ->
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3", path: '/users_uploads/'}, (fpfiles) =>
      fpfile = JSON.stringify(fpfiles[0])
      $scope.upload.image_id = fpfile
      $scope.photoPreview(fpfile)
      $scope.$apply()

  $scope.submit = () ->
    console.log this.upload
    $http.post('/uploads', this.upload).success(
      console.log 'YYAY IT WORKEd'
    )


  $scope.photoPreview = (file) ->
    width = 300
    url = JSON.parse(file).url
    src = [url , "/convert?fit=max&w=", width, "&h=", Math.floor(width * 16.0 / 9.0)].join("")
    $scope.upload.image_src = src
]