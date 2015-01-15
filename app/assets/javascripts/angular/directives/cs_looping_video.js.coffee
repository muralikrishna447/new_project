@app.service 'LoopingVideoService', [ ->
  this.videos = []

  this.addVideo = (video) ->
    this.videos.push video

  this.play = (currentScope) ->
    for scope in this.videos
      if scope == currentScope
        scope.video[0].play()
        scope.playing = true
      else
        scope.video[0].pause()
        scope.playing = false

  this
]


@app.directive 'csLoopingVideoPlayer', ['$sce', 'LoopingVideoService', ($sce, LoopingVideoService) ->
  # controller: 'VideoLoopController'
  restrict: 'A'
  scope: {
    videoUrl: '@'
  }
  templateUrl: '/client_views/cs_looping_video.html'
  controller: ($scope, $element) ->
    $scope.sliderValue = 0

    $scope.timeToSlider = (time) ->
      sliderValue = (100 / $scope.video[0].duration) * time
      return sliderValue

    $scope.sliderToTime = (sliderValue) ->
      time = sliderValue * $scope.video[0].duration / 100

    $scope.onTimeUpdate = ->
      video = $element.find 'video'
      currentTime = video[0].currentTime
      desiredTime = $scope.sliderToTime($scope.sliderValue)
      duration = video[0].duration
      console.log "currentTime: #{currentTime}"
      console.log "desiredTime: #{desiredTime}"
      console.log "duration: ", video[0].duration
      if Math.abs(currentTime - desiredTime) > 0.5 && duration - desiredTime > 0.2

        video[0].currentTime = desiredTime
      # video[0].currentTime = $scope.currentTime if currentTime - $scope.currentTime > 0.5 or $scope.currentTime - currentTime > 0.5

      $scope.$apply ->
        $scope.sliderValue = $scope.timeToSlider(video[0].currentTime)

  link: (scope, element, attrs) ->
    scope.video = element.find("video")
    scope.video[0].defaultPlaybackRate = 1
    LoopingVideoService.addVideo(scope)
    scope.playing = false

    scope.trustedVideoUrl = (videoUrl) ->
      $sce.trustAsResourceUrl(videoUrl)

    scope.toggle = ->
      if scope.playing
        scope.video[0].pause()
        scope.playing = false
      else
        LoopingVideoService.play(scope)

    # scope.speedUp = ->
    #   if scope.video[0].playbackRate >= 1
    #     newRate = scope.video[0].playbackRate + 1
    #     scope.video[0].playbackRate = newRate

    scope.$watch "videoCurrentTime", (newVal) ->
      if scope.video[0].ended
        console.log "video ended"
        # Do a second check because the last 'timeupdate'
        # after the video stops causes a hiccup.
        if scope.video[0].currentTime isnt newVal
          scope.video[0].currentTime = newVal
          scope.video[0].play()

    scope.video.bind 'timeupdate', scope.onTimeUpdate

]

# @app.directive 'csLoopingVideo', ['$sce', 'LoopingVideoService', ($sce, LoopingVideoService) ->
#   # controller: 'VideoLoopController'
#   restrict: 'A'
#   controller: ($scope, $element) ->
#     video = $element[0]
#     $scope.onTimeUpdate = ->
#       sliderValue = (100 / video.duration) * video.currentTime
#       # console.log "duration: #{video.duration}"
#       console.log "video: "
#       console.log $element
#       console.log "sliderValue: #{sliderValue}"

#   link: (scope, element, attrs) ->
#     element.bind 'timeupdate', scope.onTimeUpdate

# ]

