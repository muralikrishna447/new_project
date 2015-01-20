@app.directive 'csShowcase', ['$window', '$timeout', '$location', '$anchorScroll', '$routeParams', '$http', ($window, $timeout, $location, $anchorScroll, $routeParams, $http) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ['$scope', ($scope) ->
    $scope.collection = []
    if $scope.collectionName == 'knives'
      $http.get('/pages/knife-collection.json').success (data) ->
        mixpanel.track('Page viewed', {'title' : 'knife-collection'})
        _.each data, (item) ->
          $scope.collection.push(item)

    if $scope.collectionName == 'sous-vide'
      $http.get('/pages/sous-vide-collection.json').success (data) ->
        _.each data, (item) ->
          $scope.collection.push(item)

    annotationLineHeight = 5 # Percent
    annotationLineWidth = 10 # Percent
    $scope.annotationLineStyle = (annotation) ->
      
      
      {
        top: annotation.position.y - annotationLineHeight + '%'
        left: annotation.position.x + '%'
        height: annotationLineHeight + '%'
        width: annotationLineWidth + '%'
      }

    $scope.annotationTextStyle = (annotation) ->
      {
        top: annotation.position.y - annotationLineHeight - 3 + '%'
        left: annotation.position.x + annotationLineWidth + '%'
      }

    $scope.annotationDotStyle = (annotation) ->
      {
        top: annotation.position.y + '%'
        left: annotation.position.x + '%'
      }

    $scope.buyNowUrl = (item) ->
      productId = item.productId
      url = "http://www.epicedge.com/shopaff.asp?affid=1&id=#{productId}"
      # console.log 'the buy now url is: ', url
      return url

    $scope.currentItem = $scope.collection[0]

    # Social share callbacks
    $scope.socialURL = ->
      window.location.href

    $scope.socialTitle = ->
      ""

    $scope.socialMediaItem = ->
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/bIBHqoDWR3eLBtF8lQgu/convert?fit=crop&w=800&cache=true"

    $scope.tweetMessage = ->
      "I really want the #{$scope.currentItem.title} from #{$scope.collection[0].title}"

    $scope.toggleAnnotation = (annotation) ->

      annotation.show = !annotation.show
      console.log 'TOGGLING ANNOTATION: ', annotation

    $scope.itemClass = (item) ->
      if item.type == 'title'
        return 'cs-showcase-item-title'
      else
        return 'cs-showcase-item-standard'

    $scope.trackBuyButtonClick = (item) ->
      mixpanel.track('Buy Button Clicked', {'context' : $scope.collectionName, 'title' : item.title, 'price' : item.price})

    updateCurrent: (item, progress) ->
      if $scope.currentItem != item
        $scope.currentItem = item
        # $scope.showcaseCurrentClass = 'direction-' + $scope.direction
        # $scope.$apply()
        # $timeout ( ->
        #   $scope.currentItem = item
        #   # console.log 'currentItem is: ', $scope.currentItem
        #   # console.log 'updating Current with: ', $scope.direction
        #   $scope.showcaseCurrentClass = ''

        #   # Set the location has so anchorscrolling works
        #   # if item.id
        #   #   $location.path('/item')
        #   #   $location.hash(item.id)
        #   # else
        #   #   $location.path('')
        #   #   $location.hash('')
        #   $scope.$apply()
        # ), 100

  ]

  # link: (scope, element, attrs) ->
  #   oldPosition = 0
  #   windowElement = angular.element($window)
  #   windowElement.on 'scroll', (e) ->
  #     position = windowElement.scrollTop()
  #     # console.log 'WINDOW POSITION: ', position
  #     if oldPosition
  #       diff = oldPosition - position
  #       if diff > 0
  #         # console.log 'SCROLLING UP'
  #         scope.direction = 'up'
  #       else
  #         # console.log 'SCROLLING DOWN'
  #         scope.direction = 'down'
  #     # console.log 'oldPosition: ', oldPosition
  #     oldPosition = position

  templateUrl: '/client_views/cs_showcase.html'
]

@app.directive 'csShowcaseItem', ['$window', '$timeout', ($window, $timeout) ->
  require: '^csShowcase'
  restrict: 'A'
  scope: {
    csShowcaseItem: '='
  }

  link: (scope, element, attrs, csShowcaseController) ->
    windowElement = angular.element($window)
    windowHeight = windowElement.height()

    handleScroll = (e) ->
      el = angular.element(element)
      offset = 0.5*windowHeight
      height = el[0].offsetHeight

      start = el[0].offsetTop - offset
      end = start + height

      position = windowElement.scrollTop()
      
      # console.log 'position: ', position
      
      if start <= position < end
        # console.log 'start', start
        # console.log 'end', end
        # completed = position - start
        # progress = completed/height*100
        csShowcaseController.updateCurrent(scope.csShowcaseItem)
        element.addClass('active')
      else
        element.removeClass('active')

    windowElement.on 'scroll', (e) ->
      # handleScroll(e)
      _.throttle(handleScroll(e), 100)

    windowElement.on 'resize', (e) ->
      $scope.$apply()

]

@app.directive 'csShowcaseImage', ['csFilepickerMethods', (csFilepickerMethods) ->
  restrict: 'A'
  replace: true
  scope: {
    csShowcaseImage: '='
  }

  controller: ['$scope', ($scope) ->
    $scope.getImageUrl = (fp) ->
      imageWidth = null
      windowWidth = window.innerWidth
      if windowWidth <= 480
        imageWidth = 480
      else if windowWidth <= 767
        imageWidth = 767
      else if windowWidth <= 1600
        imageWidth = 1600
      else
        imageWidth = 3000
      csFilepickerMethods.convert(fp, {width: imageWidth})
  ]

  link: (scope, element, attrs) ->

    element.on 'load', (e) ->
      height = element[0].height
      scope.csShowcaseImage.imageHeight = height

  template:
    """
      <img src="{{getImageUrl(csShowcaseImage.fp)}}"/>
    """
]