# create youtube player
onYouTubePlayerAPIReady = ->
  player = new YT.Player("spherification-player",
    videoId: "QPdO4I3WLHg"
    events:
      onReady: onPlayerReady
      onStateChange: onPlayerStateChange
  )

# autoplay video
onPlayerReady = (event) ->
  event.target.playVideo()

# when video ends
onPlayerStateChange = (event) ->
  if event.data is 0
    console.log('done')
player = undefined