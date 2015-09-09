# TODO:
# Track video title and maybe containing object (i.e. activity) title?
# Set width, height, maybe other params from attrs
# Set up two-way binding for scope and change videos when the id changes
# Maybe track more events beside load and play

@app.directive 'csembedyoutube', ["$timeout", "$window", ($timeout, $window) ->
  restrict: 'E'
  scope: { autoplay: '=' }
  link: (scope, element, attrs) ->
    player = null
    playerId = "YT" + Date.now()
    $(element).find('.video-iframe').attr('id', playerId)

    createPlayer = ->
      if window.youtubeAPIReady && attrs.videoId
        console.log('createPlayer')
        player = new YT.Player(
          playerId,
          videoId: attrs.videoId
          playerVars:
            'wmode': 'opaque'
            'modestbranding' : 1
            'rel': 0
            'showinfo': 0
            'width': 1466
            'iv_load_policy': 3
            'autoplay': attrs.autoplay || 0
            'playsinline' : 0

          events:
            # Youtube player is clever enough to default a playback quality based on size
            # but not to adjust it when going fullscreen.
            'onReady' : (event) ->
              console.log("onReady #{player.getVideoUrl()}")
              player.setPlaybackQuality?('hd1080')
        )
      else
        # If the YT api isn't ready yet, try again a little later
        $timeout (-> createPlayer()), 500

    createPlayer()

    scope.$on 'playVideo', (event, play) ->
      console.log("playVideo: #{play}")

      # GD ios/yt. Not only does playVideo() not *work*, it actually causes the YT
      # frame to be completely black, not even any chrome. Awesome.
      if play
        if ! /(iPad|iPhone|iPod)/g.test( navigator.userAgent )
          player?.playVideo()

      else
        player?.pauseVideo()

      # Seems to help with occasional pillarboxing
      $timeout ( ->
       scope.adjustHeight(1)
      ), 1000

    attrs.$observe 'videoId', ->
      if player? && player.loadVideoById?
        console.log("cueVideo: #{attrs.videoId}")
        # want cue, not load. Load starts it playing.
        player?.cueVideoById?(attrs.videoId, 0, 'hd1080')

    scope.adjustHeight = () ->
      newHeight = Math.round(scope.getWidth() * (attrs.aspectRatio || (9.0 / 16.0)))
      console.log("new height #{newHeight}")
      $(element).find('iframe').height(newHeight)

    scope.getWidth = ->
      $(element).find('iframe').width()

    scope.$watch scope.getWidth, ( ->
      scope.adjustHeight()
    ), true

    angular.element($window).bind "resize", ->
      scope.$apply()

  template: """
    <div class="video-iframe-container">
      <div class='video-iframe'></div>
    </div>
  """
]