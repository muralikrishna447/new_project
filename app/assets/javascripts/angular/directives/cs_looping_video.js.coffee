@app.service 'LoopingVideoService', [ ->
  this.videos = []

  this.addVideo = (video) ->
    this.videos.push video

  this.play = (currentScope) ->
    for scope in this.videos
      if scope == currentScope
        scope.video.play()
        scope.playing = true
      else
        scope.video.pause()
        scope.playing = false

  this
]


@app.directive 'csLoopingVideo', ['$sce', 'LoopingVideoService', ($sce, LoopingVideoService) ->
  # controller: 'VideoLoopController'
  restrict: 'A'
  scope: {
    videoUrl: '@'
  }
  templateUrl: '/client_views/cs_looping_video.html'
  link: (scope, element, attrs) ->
    scope.video = element.find("video")[0]
    LoopingVideoService.addVideo(scope)
    scope.playing = false

    scope.trustedVideoUrl = (videoUrl) ->
      $sce.trustAsResourceUrl(videoUrl)

    scope.toggle = ->
      if scope.playing
        scope.video.pause()
        scope.playing = false
      else
        LoopingVideoService.play(scope)
]

