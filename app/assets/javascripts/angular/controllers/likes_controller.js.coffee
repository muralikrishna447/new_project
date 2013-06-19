angular.module('ChefStepsApp').controller 'LikesController', ["$scope", "$resource", "$location", "$http", ($scope, $resource, $location, $http) ->
  
  $scope.likeObject = (likeable_type, likeable_id) ->
    url = '/likes?likeable_type=' + likeable_type + '&likeable_id=' + likeable_id
    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
      $scope.current_user_likes = true
      $scope.likes_count += 1
      # TODO will eventually need to angularize the alert notification system
      $('.alert-container').append("<div class='alert alert-success'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'>You liked this!</h4><div class='lblock'></div></div>")
    ).error((data, status, headers, config) ->
      $('.alert-container').append("<div class='alert alert-error'><button class='close' data-dismiss='alert' type='button'>x</button><h4 class='alert-message'><a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to like this.</h4><div class='lblock'></div></div>")
    )
]