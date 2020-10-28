# Video Looping service that allows only one looping video to play at a time.
@app.service 'LoopingVideoManager', ['$document', '$location', ($document, $location) ->
  this.videos = []

  this.addVideoScope = (scope) ->
    this.videos.push scope

  this.removeScope = (currentScope) ->
    videos = this.videos
    videos.forEach (scope, i) ->
      if scope == currentScope
        videos.splice(i,1)

  this.play = (currentScope) ->
    for scope in this.videos
      if scope == currentScope
        scope.video[0].play()
        scope.playing = true
      else
        scope.video[0].pause()
        scope.playing = false

  this.pause = (currentScope) ->
    currentScope.video[0].pause()
    currentScope.playing = false

  angular.element($document[0].body).on 'click', (e) =>
    videos = this.videos
    service = this
    console.log "clicked the body: #{e}"
    isVideoLoop = angular.element(e.target).inheritedData('videoLoop')
    console.log "isVideoLoop: #{isVideoLoop}"
    if isVideoLoop != true
      console.log "pausing video"
      videos.forEach (scope, i) ->
        if scope.playing
          service.pause scope
      # this.pause()

  this
]

# Video Looping directive which can be used like a standard directive or as a shortcode as defined in shortcode.js.coffee

# To use as directive:
# <div cs-looping-video-player video-name="somevideoname"></div>

# To use as a shortcode:
# [videoLoop somevideoname]
@app.directive 'csLoopingVideoPlayer', ['$sce', 'LoopingVideoManager', '$timeout', '$location', ($sce, LoopingVideoManager, $timeout, $location) ->
  restrict: 'A'
  scope: {
    videoName: '@'
    videoImage: '@'
  }
  templateUrl: '/client_views/cs_looping_video.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.video = $element.find("video")
    $scope.video[0].defaultPlaybackRate = 1
    $scope.playbackRate = 1
    LoopingVideoManager.addVideoScope($scope)
    $scope.playing = false
    $scope.sliderValue = 0
    $scope.baseUrl = "https://d29uyzek4esgj1.cloudfront.net/"

    if $scope.videoName
      $scope.sources = [
        $scope.baseUrl + $scope.videoName + "-480p.mp4"
        $scope.baseUrl + $scope.videoName + "-480p.webm"
      ]

    # Helper to convert time into a slider value
    $scope.timeToSlider = (time) ->
      sliderValue = (100 / $scope.video[0].duration) * time
      return sliderValue

    # Helper to convert slider value to a time
    $scope.sliderToTime = (sliderValue) ->
      time = sliderValue * $scope.video[0].duration / 100

    # Only update if the time change comes from video and not the user
    $scope.onTimeUpdate = ->
      if !$scope.mousedown
        video = $element.find 'video'
        currentTime = video[0].currentTime
        desiredTime = $scope.sliderToTime($scope.sliderValue)
        duration = video[0].duration

        $scope.$apply ->
          $scope.sliderValue = $scope.timeToSlider(currentTime)
  ]
  link: (scope, element, attrs) ->
    element.data('videoLoop', true)

    scope.trustedVideoUrl = (videoUrl) ->
      $sce.trustAsResourceUrl(videoUrl)

    scope.toggle = ->
      if scope.playing
        LoopingVideoManager.pause(scope)
        
      else
        LoopingVideoManager.play(scope)

    scope.setRate = (rate) ->
      scope.playbackRate = rate
      scope.video[0].playbackRate = rate
      scope.showDisplay = true
      $timeout (->
        scope.showDisplay = false
      ), 1000

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

    scope.onmousedown = ->
      scope.mousedown = true
      LoopingVideoManager.pause(scope)
      console.log "Slider Focused: #{scope.mousedown}"

    scope.onmouseup = ->
      scope.mousedown = false
      LoopingVideoManager.play(scope)
      console.log "Slider Focused: #{scope.mousedown}"

    scope.$watch 'sliderValue', (newValue, oldValue) ->
      if scope.mousedown && newValue != oldValue
        scope.video[0].currentTime = scope.sliderToTime(newValue)
        console.log "Video current time updated"

    scope.video.bind 'timeupdate', scope.onTimeUpdate

    # If the directive element is removed from dom, $destroy will be called and we'll make sure the scope is removed from the Looping Video Manager
    element.bind '$destroy', ->
      LoopingVideoManager.removeScope(scope)
]

