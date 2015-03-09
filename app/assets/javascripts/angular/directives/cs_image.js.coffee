###
A much simpler cs-image directive puts correct image size depending on its parent width and reduces the number if image converts.

Usage:

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'")

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" aspect="16:9")

###

@app.directive 'csImage', ['csFilepickerMethods', (csFilepickerMethods) ->
  restrict: 'E'
  scope: {
    url: '='
    aspect: '@'
  }

  link: (scope, element, attrs) ->
    scope.containerStyle = {}
    parent = element.parent()
    parent.width = $(parent[0]).width()

    if parent.width <= 400
      finalWidth = 400
    else if 400 < parent.width <= 800
      finalWidth = 800
    else
      finalWidth = 1200

    if scope.aspect && scope.aspect == "16:9"
      finalHeight = finalWidth * 9 / 16
      scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: finalWidth, h: finalHeight, fit: 'clip'})
    else
      scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: finalWidth})
    scope.containerStyle["opacity"] = "1"

  template:
    """
    <div ng-style="containerStyle" class="cs-image">
      <img ng-src="{{finalUrl}}">
    </div>
    """

]