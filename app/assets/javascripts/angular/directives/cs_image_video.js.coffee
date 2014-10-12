@app.directive 'csImageVideo', ['$sce', '$window', '$timeout', 'csFilepickerMethods', ($sce, $window, $timeout, csFilepickerMethods) ->
  restrict: 'E'
  scope: {
    image: '='
    video: '='
  }

  link: (scope, element, attrs) ->
    scope.buttonClass = 'button-active'
    scope.imageClass = 'image-active'
    scope.videoClass = 'video-inactive'

    scope.togglePlay = ->
      scope.buttonClass = if scope.buttonClass == 'button-active' then 'button-inactive' else 'button-active'
      scope.imageClass = if scope.imageClass == 'image-active' then 'image-inactive' else 'image-active'
      scope.videoClass = if scope.videoClass == 'video-active' then 'video-inactive' else 'video-active'
      showVideo = if scope.videoClass =='video-active' then true else false
      scope.$broadcast('playVideo', showVideo)

    scope.imageUrl = (image) ->
      # csFilepickerMethods.cdnURL(image)
      csFilepickerMethods.convert(image, {width: 1200})

    scope.videoUrl = (video) ->
      $sce.trustAsResourceUrl('http://www.youtube.com/embed/' + scope.video + '?wmode=opaque')

    scope.$watch 'image', (newValue, oldValue) ->
      if newValue != oldValue
        scope.buttonClass = 'button-active'
        scope.imageClass = 'image-active'
        scope.videoClass = 'video-inactive'

    scope.initialElementWidth = element[0].clientWidth
    adjustWidth = ->
      elementWidth = element[0].clientWidth
      maxHeight = 600
      widthAtMaxHeight = 500*16/9
      console.log 'width max height: ', widthAtMaxHeight
      
      videoElement = element.find('.cs-video')
      if elementWidth > widthAtMaxHeight
        # Set max height to max height
        element.height(maxHeight)
        marginLeft = (elementWidth - widthAtMaxHeight)/2
        videoWidth = widthAtMaxHeight

        videoElement.css('width', videoWidth)
          .css('margin-left', marginLeft)
      else
        element.height(elementWidth*9/16)
        # element.height('inherit')
        videoElement.css('width', 'inherit')
          .css('margin-left', 'inherit')

    angular.element($window).bind 'resize', ->
      adjustWidth()

    scope.$watch 'initialElementWidth', (newValue, oldValue) ->
      console.log 'new value: ', newValue
      console.log 'old value: ', oldValue
      adjustWidth()

  templateUrl: '/client_views/cs_image_video.html'
]