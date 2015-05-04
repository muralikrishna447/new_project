@app.directive 'csembedvideo', [ ->
  restrict: 'E'
  scope: { vimeoId: "@", youtubeId: "@", autoplay: '@', containerSlug: '@'}
  link: (scope, element, attrs) ->


  template: """
    <div>
      <csembedvimeo ng-if="vimeoId" video-id="{{vimeoId}}" autoplay="autoplay" containerSlug="containerSlug"></csembedvimeo>
      <csembedyoutube ng-if="! vimeoId && youtubeId" video-id="{{youtubeId}}" autoplay="autoplay" containerSlug="containerSlug"></csembedyoutube>
    </div>
  """
]