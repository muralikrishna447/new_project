  window.BaseMediaController = ($scope) ->

    # Video/image stuff
    $scope.hasHeroVideo = ->
      $scope.getObject()?.youtube_id? && $scope.getObject().youtube_id

    $scope.hasHeroImage = ->
      $scope.getObject()?.image_id? && $scope.getObject().image_id

    $scope.hasFeaturedImage = ->
      $scope.getObject()?.featured_image_id? && $scope.getObject().featured_image_id

    $scope.heroVideoURL = ->
      autoplay = if $scope.url_params.autoplay then "1" else "0"
      "//www.youtube.com/embed/#{$scope.activity.youtube_id}?wmode=opaque\&rel=0&modestbranding=1\&showinfo=0\&vq=hd720\&autoplay=#{autoplay}"

    $scope.heroVideoStillURL = ->
      "//img.youtube.com/vi/#{$scope.getObject().youtube_id}/0.jpg"

    $scope.heroImageURL = (width) ->
      url = ""
      if $scope.hasHeroImage()
        url = JSON.parse($scope.getObject().image_id).url
        url + "/convert?fit=max&w=#{width}&cache=true"
      window.cdnURL(url)

    $scope.featuredImageURL = (width) ->
      url = ""
      if $scope.hasFeaturedImage()
        url = JSON.parse($scope.getObject().featured_image_id).url
        url = url + "/convert?fit=max&w=#{width}&cache=true"
      window.cdnURL(url)

    $scope.heroDisplayType = ->
      return "video" if $scope.hasHeroVideo()
      return "image" if $scope.hasHeroImage()
      return "none"
