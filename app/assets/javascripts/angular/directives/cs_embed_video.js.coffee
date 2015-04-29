@app.directive 'csembedvideo', [ ->
  restrict: 'E'
  scope: { autoplay: '@', vimeoId: "@", youtubeId: "@" }
  link: (scope, element, attrs) ->


  template: """
    <div>
      <csembedvimeo ng-if="vimeoId" video-id="{{vimeoId}}"></csembedvimeo>
      <csembedyoutube ng-if="! vimeoId && youtubeId" video-id="{{youtubeId}}" autoplay="autoplay"></csembedyoutube>
    </div>
  """
]