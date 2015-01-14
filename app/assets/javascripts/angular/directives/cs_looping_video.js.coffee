@app.directive 'csLoopingVideo', ["$sce", ($sce) ->
  restrict: 'A'
  scope: {
    videoUrl: '@'
  }
  templateUrl: '/client_views/cs_looping_video.html'
  link: (scope, element, attrs) ->

    scope.trustedVideoUrl = (videoUrl) ->
      $sce.trustAsResourceUrl(videoUrl)

    scope.play = ->
      video = element.find("video")[0]
      video.play()
]