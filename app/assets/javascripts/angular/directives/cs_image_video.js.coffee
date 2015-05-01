# Directive that takes an image and a video and creates an interactive element.
# The directive uses the image as a cover photo and adds a play button.
# Usage:
# %cs-image-video(image='IMAGE_ID' video='YOUTUBE_ID')
# Usage example: Hero Image/Video for recipes
# Future improvements:
#   Get it to work with cs-image
#   Have it accept image url as well as Filepicker objects
#   Generalize video so it accepts any url and not just a youtube_id
#   A way to specify the size other than width 100% and height 600
# Bugs:
#   Autoplay doesn't seem to be working on iOS8 at the time of writing this

@app.directive 'csImageVideo', ['$sce', '$window', '$timeout', 'csFilepickerMethods', ($sce, $window, $timeout, csFilepickerMethods) ->
  restrict: 'E'
  scope: {
    image: '='
    youtubeId: '='
    vimeoId: '='
  }

  link: (scope, element, attrs) ->
    scope.buttonClass = 'button-active'
    scope.imageClass = 'image-active'
    scope.videoClass = 'video-inactive'

    scope.hasVideo = ->
      scope.youtubeId || scope.videoId

    scope.togglePlay = ->
      scope.buttonClass = if scope.buttonClass == 'button-active' then 'button-inactive' else 'button-active'
      scope.imageClass = if scope.imageClass == 'image-active' then 'image-inactive' else 'image-active'
      scope.videoClass = if scope.videoClass == 'video-active' then 'video-inactive' else 'video-active'
      showVideo = if scope.videoClass =='video-active' then true else false
      scope.$broadcast('playVideo', showVideo)

    scope.imageUrl = (image) ->
      # csFilepickerMethods.cdnURL(image)
      csFilepickerMethods.convert(image, {width: 1200})

    scope.$watch 'image', (newValue, oldValue) ->
      if newValue != oldValue
        scope.buttonClass = 'button-active'
        scope.imageClass = 'image-active'
        scope.videoClass = 'video-inactive'

  templateUrl: '/client_views/cs_image_video.html'
]