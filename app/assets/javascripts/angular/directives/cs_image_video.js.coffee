@app.directive 'csImageVideo', ['$sce', 'csFilepickerMethods', ($sce, csFilepickerMethods) ->
  restrict: 'E'
  scope: {
    image: '='
    video: '='
  }

  link: (scope, element, attrs) ->
    scope.imageClass = 'image-active'
    scope.videoClass = 'video-inactive'

    scope.togglePlay = ->
      scope.imageClass = if scope.imageClass == 'image-active' then 'image-inactive' else 'image-active'
      scope.videoClass = if scope.videoClass == 'video-active' then 'video-inactive' else 'video-active'

    scope.imageUrl = (image) ->
      csFilepickerMethods.cdnURL(image)

    scope.videoUrl = (video) ->
      $sce.trustAsResourceUrl('http://www.youtube.com/embed/' + scope.video + '?wmode=opaque')

    scope.$watch 'image', (newValue, oldValue) ->
      if newValue != oldValue
        scope.imageClass = 'image-active'
        scope.videoClass = 'video-inactive'

  templateUrl: '/client_views/cs_image_video.html'
]