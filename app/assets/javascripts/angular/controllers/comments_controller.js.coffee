angular.module('ChefStepsApp').controller 'CommentsController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->

  $scope.init = (commentable_type, commentable_id, currentUserID, isReviews = false) ->
    $scope.commentable_type = commentable_type
    $scope.commentable_id = commentable_id
    $scope.currentUserID = currentUserID
    $scope.isReviews = isReviews
    $scope.defaultCommentLimit = 6
    $scope.commentLimit = $scope.defaultCommentLimit
    $scope.commentLimit *= -1 if ! isReviews
    $scope.newComment = {rating: 0, content: "", user_id: currentUserID}

    $scope.Comment = $resource('/' + $scope.commentable_type + '/' + $scope.commentable_id + '/comments')
    $scope.comments = $scope.Comment.query(->
      $scope.comments_count = $scope.comments.length
    ) 

  $scope.userImageUrl = (image_id) ->
    if image_id
      image = JSON.parse(image_id)
      window.cdnURL(image.url + '/convert?fit=crop&w=30&h=30&cache=true')
    else
      window.cdnURL('https://www.filepicker.io/api/file/yklhkH0iRV6biUOcXKSw/convert?fit=crop&w=30&h=30&cache=true')

  $scope.addComment = ->
    comment = $scope.Comment.save($scope.newComment, ->
      $scope.comments.push(comment)
      $scope.newComment = {}
      $scope.comments_count = $scope.comments.length
    )
    $scope.showReviewInput = false

  $scope.commentsToggle = ->
    if $scope.comments.length > $scope.defaultCommentLimit
      true
    else
      false

  $scope.showAllComments = ->
    $scope.commentLimit = $scope.comments_count

  $scope.hideComments = ->
    $scope.commentLimit = $scope.defaultCommentLimit
    $scope.commentLimit *= -1 if ! isReviews

  $scope.reviewProblems = (review) ->
    return null if ! review
    # Not fully in use yet, would need visual feedback; then could use a number > 1 for required length
    return "Please choose a star rating" if review.rating < 1
    return (1 - review.content.length) + " more characters required" if review.content.length < 1
    return ""

  $scope.myReview = ->
    _.find($scope.comments, (c) -> c.user_id == $scope.currentUserID)

]
