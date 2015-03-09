###
A much simpler cs-image directive puts correct image size depending on its parent width and reduces the number if image converts.

Usage:

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'")

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" aspect="16:9")

###

@app.directive 'csImage', ['csFilepickerMethods', '$window', (csFilepickerMethods, $window) ->
  restrict: 'E'
  scope: {
    url: '='
    aspect: '@'
  }

  link: (scope, element, attrs) ->
    scope.containerStyle = {}
    parent = element.parent()

    scope.calculateWidth = ->
      parent.width = $(parent[0]).width()

      if parent.width <= 280
        scope.finalWidth = 280
      else if 280 < parent.width <= 400
        scope.finalWidth = 400
      else if 400 < parent.width <= 800
        scope.finalWidth = 800
      else
        scope.finalWidth = 1200

      if scope.aspect && scope.aspect == "16:9"
        finalHeight = scope.finalWidth * 9 / 16
        scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: scope.finalWidth, h: finalHeight})
      else
        scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: scope.finalWidth})
      scope.containerStyle["opacity"] = "1"

    angular.element($window).on 'resize', ->
      scope.calculateWidth()
      scope.$apply()

    scope.calculateWidth()

  template:
    """
    <div ng-style="containerStyle" class="cs-image">
      <img ng-src="{{finalUrl}}">
    </div>
    """

]