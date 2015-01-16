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
    $scope.video = $element.find("video")
    $scope.video[0].defaultPlaybackRate = 1
    $scope.playbackRate = 1
    LoopingVideoService.addVideo($scope)
    $scope.playing = false
    $scope.sliderValue = 0

    $scope.timeToSlider = (time) ->
      sliderValue = (100 / $scope.video[0].duration) * time
      return sliderValue

    $scope.sliderToTime = (sliderValue) ->
      time = sliderValue * $scope.video[0].duration / 100

    $scope.onTimeUpdate = ->
      if !$scope.mousedown
        video = $element.find 'video'
        currentTime = video[0].currentTime
        desiredTime = $scope.sliderToTime($scope.sliderValue)
        duration = video[0].duration

        $scope.$apply ->
          $scope.sliderValue = $scope.timeToSlider(currentTime)

  link: (scope, element, attrs) ->

    scope.trustedVideoUrl = (videoUrl) ->
      $sce.trustAsResourceUrl(videoUrl)

    scope.toggle = ->
      if scope.playing
        scope.video[0].pause()
        scope.playing = false
      else
        LoopingVideoService.play(scope)

    scope.setRate = (rate) ->
      scope.playbackRate = rate
      scope.video[0].playbackRate = rate

    scope.speedUp = ->
      currentRate = scope.video[0].playbackRate
      if currentRate >= 1
        newRate = currentRate + 1
      else
        newRate = currentRate * 2
      scope.setRate(newRate)

    scope.slowDown = ->
      currentRate = scope.video[0].playbackRate
      if currentRate > 1
        newRate = currentRate - 1
      else
        newRate = currentRate / 2
      scope.setRate(newRate)

    scope.onmousedown = (e) ->
      scope.mousedown = true
      scope.video[0].pause()
      console.log "Slider Focused: #{scope.mousedown}"

    scope.onmouseup = (e) ->
      scope.mousedown = false
      LoopingVideoService.play(scope)
      console.log "Slider Focused: #{scope.mousedown}"

    scope.$watch 'sliderValue', (newValue, oldValue) ->
      if scope.mousedown && newValue != oldValue
        scope.video[0].currentTime = scope.sliderToTime(newValue)
        console.log "Video current time updated"

    scope.video.bind 'timeupdate', scope.onTimeUpdate

]

