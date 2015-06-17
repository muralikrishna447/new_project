###
A much simpler cs-image directive puts correct image size depending on its parent width and reduces the number if image converts.

Usage:

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'")

%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" aspect="16:9")

###

@helpers.directive 'csImage', ['csFilepickerMethods', '$window', '$timeout', (csFilepickerMethods, $window, $timeout) ->
  restrict: 'E'
  scope: {
    url: '='
    aspect: '@'
  }

  link: (scope, element, attrs) ->
    scope.containerStyle = {}
    scope.attrs = attrs
    parent = element.parent()
    scope.calculateWidth = ->
      parent.width = $(parent[0]).width()

      # Round up to nearest 50px - don't want to just use parent.width
      # because that will cause a ton of refetches in a fluid layout during resize.
      scope.finalWidth = Math.ceil(parent.width / 50.0) * 50

      if scope.aspect
        switch scope.aspect
          # Use aspect container when the container has both height and width defined
          when "container"
            parent.height = $(parent[0]).height()
            scope.finalHeight = scope.finalWidth * parent.height/parent.width
          when "1:1"
            scope.finalHeight = scope.finalWidth
          when "16:9"
            scope.finalHeight = scope.finalWidth * 9 / 16
          when "3:1"
            scope.finalHeight = scope.finalWidth * 1 / 3
        scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: scope.finalWidth, h: scope.finalHeight})

      else
        scope.finalUrl = csFilepickerMethods.convert(scope.url, {w: scope.finalWidth})
      scope.containerStyle["opacity"] = "1"

    angular.element($window).on 'resize', ->
      scope.calculateWidth()
      scope.$apply()

    scope.$watch 'url', (newValue, oldValue) ->
      if newValue
        scope.calculateWidth()

  template:
    """
    <div ng-style="containerStyle" class="cs-image">
      <img ng-src="{{finalUrl}}" alt="{{attrs.alt}}" title="{{attrs.title}}" width="{{finalWidth}}" height="{{finalHeight || ''}">
    </div>
    """

]
