@app.service 'BloomSettings', ['$q', 'csAuthentication', ($q, csAuthentication) ->
  @user = csAuthentication.currentUser().id
  @token = csAuthentication.currentUser().authentication_token
  @getUser = (id) =>
    def = $q.defer()

    $http.get('/users/' + id).success (data,status) ->
      data.avatarUrl = data['avatar_url']
      def.resolve data
   
    def.promise

  return this
]

@app.controller 'csCommentsController', ["$scope", "$http", "csAuthentication", ($scope, $http, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()

  $scope.getName = ->
    console.log $scope.currentUser
    # console.log $scope.currentUser.name

  $scope.getAvatarUrl = ->
    imageId = JSON.parse($scope.currentUser.image_id)
    imageUrl = imageId.url.replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    console.log imageUrl

  $scope.getMe = ->
    console.log $scope.currentUser.id

  $scope.getUser = (id) ->
    $http.get('/users/' + id).success (data,status) ->
      console.log data

  # $scope.getName()
  # $scope.getAvatarUrl()
  # $scope.getMe()

]