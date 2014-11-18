@app.directive 'csShowcase', ['$window', ($window) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ['$scope', ($scope) ->

    if $scope.collectionName == 'knives'
      $scope.collection = [
        {
          id: 1
          title: 'Asai'
          description: 'High in the Japanese Alps, in the small town of Takefu in the Fukui Prefecture, fifth-generation blacksmith Masami Asai forges some of the most distinctive handmade kitchen knives in the world. His knives are both elegant and functional, made with the highest grade carbon steel alloy for perfect edge retention, and finished with graceful details like mocha-colored Makassar ebony and rich Pakkawood ferrules. Together with four other bladesmiths in the region, Asai opened a knifemaking school in Takefu in 1993, where he and others teach the artistry and tradition of handmade knifemaking to the next generation. Asai is a living legend among Japanese knifemakers, well-known by chefs worldwide for his delicate handiwork.'
          imageUrl: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/5PSozfGPRJiTkQpha6rI?cache=true'
          isCurrent: false
        }
        {
          id: 2
          title: 'Oishi Hammer'
          description: "Ohishi produces some of the finest-quality factory knives in the world, with stylized, ultra-thin blades that surpass most German and American handmade knives in both performance and beauty. At Ohishi, a small team of twenty-or-so blacksmiths and artisans design and forge knives with a characteristically thin blade geometry for clean cutting, and western-style riveted handles. The company, named after a small village at the foot of Mt Fuji where lavender grows rampant, set out to introduce high-performance knives at affordable prices, and they’ve done just that."
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/v5IsZcj3TFa3KmA6w0pB?cache=true"
          isCurrent: false
        }
      ]

      $scope.annotations = [
        {
          type: 'spacer'
        }
        {
          type: 'title'
          title: 'Asai'
          description: 'High in the Japanese Alps, in the small town of Takefu in the Fukui Prefecture, fifth-generation blacksmith Masami Asai forges some of the most distinctive handmade kitchen knives in the world. His knives are both elegant and functional, made with the highest grade carbon steel alloy for perfect edge retention, and finished with graceful details like mocha-colored Makassar ebony and rich Pakkawood ferrules. Together with four other bladesmiths in the region, Asai opened a knifemaking school in Takefu in 1993, where he and others teach the artistry and tradition of handmade knifemaking to the next generation. Asai is a living legend among Japanese knifemakers, well-known by chefs worldwide for his delicate handiwork.'
          parentId: 1
        }
        {
          type: 'right'
          title: 'Asai Petty Knife'
          description: "This high-performance detail knife is made with the finest Japanese carbon steel for exceptional edge holding. The blade's hand-hammered surface helps release food from the knife when cutting. The octagonal ambidextrous handle is made of rich Makassar ebony with Pakkawood ferrules. [5-1/3 inches, 82 g]"
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/nmsJg1TpSmiClRMvNqvb?cache=true"
          price: '40.00'
          parentId: 1
          position: {
            x: 58
            y: 28
          }
        }
        {
          type: 'right'
          title: "Asai Chef's Knife"
          description: "Modeled after the French chef’s blade but with all the grace and beauty of a Japanese handmade knife, this Gyuto is exceptionally versatile as a general chef’s knife. The core is made of the finest Japanese carbon steel for unparalleled edge holding, and the blade’s distal tapering provides optimal balance and weight. A Makassar ebony handle and Pakkawood ferrules further classify this knife as a work of art. [8-1/4 inches, 193 grams]"
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SUsrjsPbRyOzjSJwtFl3?cache=true"
          price: '80.00'
          parentId: 1
          position: {
            x: 60
            y: 49
          }
        }
        {
          type: 'spacer'
        }
        {
          type: 'title'
          title: 'Oishi'
          description: "Ohishi produces some of the finest-quality factory knives in the world, with stylized, ultra-thin blades that surpass most German and American handmade knives in both performance and beauty. At Ohishi, a small team of twenty-or-so blacksmiths and artisans design and forge knives with a characteristically thin blade geometry for clean cutting, and western-style riveted handles. The company, named after a small village at the foot of Mt Fuji where lavender grows rampant, set out to introduce high-performance knives at affordable prices, and they’ve done just that."
          parentId: 2
        }
        {
          type: 'right'
          title: "Oishi Petty Knife"
          description: "This high-performance detail knife is made with the finest Japanese carbon steel for exceptional edge holding. The blade's hand-hammered surface helps release food from the knife when cutting. The octagonal ambidextrous handle is made of rich Makassar ebony with Pakkawood ferrules. [5-1/3 inches, 82 g]"
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/nmsJg1TpSmiClRMvNqvb?cache=true"
          price: '40.00'
          parentId: 2
          position: {
            x: 65
            y: 80
          }
        },
        {
          type: 'right'
          title: "Oishi Chef's Knife"
          description: "Modeled after the French chef’s blade but with all the grace and beauty of a Japanese handmade knife, this Gyuto is exceptionally versatile as a general chef’s knife. The core is made of the finest Japanese carbon steel for unparalleled edge holding, and the blade’s distal tapering provides optimal balance and weight. A Makassar ebony handle and Pakkawood ferrules further classify this knife as a work of art. [8-1/4 inches, 193 grams]"
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SUsrjsPbRyOzjSJwtFl3?cache=true"
          price: '80.00'
          parentId: 2
          position: {
            x: 25
            y: 80
          }
        }
      ]

    $scope.currentItem = $scope.collection[0]
    $scope.currentAnnotation = null

    _.each $scope.annotations, (item) ->
      item.class = "cs-showcase-item-" + item.type

    $scope.isCurrent = (item) ->
      if $scope.currentItem.id == item.id
        true
      else
        false

    updateCurrent: (item) ->
      if $scope.currentAnnotation != item
        $scope.currentAnnotation = item

        # Set annotation style
        if item.position
          $scope.showAnnotations = true
          $scope.currentItem.currentAnnotationStyle = {
            top: item.position.y + '%'
            left: item.position.x + '%'
          }
        else
          $scope.showAnnotations = false

        if item.parentId
          if $scope.currentItem.id != item.parentId
            currentItem = _.where($scope.collection, {id: item.parentId})[0]
            $scope.currentItem = currentItem

        $scope.$apply()

      # if $scope.currentAnnotation != item
      #   $scope.currentAnnotation = item

      #   # Set annotation style
      #   if item.position
      #     $scope.currentAnnotationStyle = {
      #       top: item.position.y + '%'
      #       left: item.position.x + '%'
      #     }

      #   # Set Current Collection Item
        
      #   if item.parentId
      #     current = _.where($scope.collection, {id: item.parentId})
      #     currentItem = current[0]
      #     if $scope.currentItem != currentItem
      #       $scope.currentItem = currentItem
      #     $scope.showImage = true
      #   else
      #     $scope.showImage = false
      #   $scope.$apply()

  ]

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
    # imageElement = element.find('img')
    # console.log 'image: ', imageElement

    angular.element($window).on 'scroll', (e) ->
      el = angular.element(element)
      offset = 0.5*windowHeight
      height = el[0].offsetHeight

      start = el[0].offsetTop - offset
      end = start + height

      position = windowElement.scrollTop()
      
      console.log 'position: ', position
      
      if start <= position < end
        console.log 'current item: ', scope.csShowcaseItem.title
        console.log 'start: ', start
        console.log 'end: ', end
        csShowcaseController.updateCurrent(scope.csShowcaseItem)

        completed = position - start
        progress = completed/height*100
        console.log 'progress: ' + progress + '%'

        if 5 <= progress <= 95
          element.addClass('active')
          if 50 <= progress <= 95
            # imageElement.addClass('active')
            element.addClass('with-image')
          else
            # imageElement.removeClass('active')
            element.removeClass('with-image')
        else
          element.removeClass('active')
      else
        element.removeClass('active')

]
