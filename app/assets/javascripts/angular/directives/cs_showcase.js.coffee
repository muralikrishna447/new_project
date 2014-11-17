@app.directive 'csGetRects', ['$window', '$timeout', ($window, $timeout) ->
  restrict: 'A'
  scope: {
    csGetRects: '='
  }

  link: (scope, element, attrs) ->

    $timeout ( ->
      console.log 'Get rects attrs: ', scope.csGetRects
      scope.start = element[0].getBoundingClientRect().top
      scope.end = angular.element(element).height()
      console.log 'Get rects scope: ', scope
    ), 5000
]

@app.directive 'csShowcase', ['$window', ($window) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ($scope) ->
    if $scope.collectionName == 'knives'
      $scope.collection = [
        {
          title: 'Asai'
          description: 'High in the Japanese Alps, in the small town of Takefu in the Fukui Prefecture, fifth-generation blacksmith Masami Asai forges some of the most distinctive handmade kitchen knives in the world. His knives are both elegant and functional, made with the highest grade carbon steel alloy for perfect edge retention, and finished with graceful details like mocha-colored Makassar ebony and rich Pakkawood ferrules. Together with four other bladesmiths in the region, Asai opened a knifemaking school in Takefu in 1993, where he and others teach the artistry and tradition of handmade knifemaking to the next generation. Asai is a living legend among Japanese knifemakers, well-known by chefs worldwide for his delicate handiwork.'
          imageUrl: 'https://d3awvtnmmsvyot.cloudfront.net/api/file/5PSozfGPRJiTkQpha6rI?cache=true'
          annotations: [
            {
              x: '30'
              y: '50'
              title: 'Asai Petty Knife'
              description: "This high-performance detail knife is made with the finest Japanese carbon steel for exceptional edge holding. The blade's hand-hammered surface helps release food from the knife when cutting. The octagonal ambidextrous handle is made of rich Makassar ebony with Pakkawood ferrules. [5-1/3 inches, 82 g]"
              imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/nmsJg1TpSmiClRMvNqvb?cache=true"
              price: '40.00'
            },
            {
              x: '10'
              y: '80'
              title: "Asai Chef's Knife"
              description: "Modeled after the French chef’s blade but with all the grace and beauty of a Japanese handmade knife, this Gyuto is exceptionally versatile as a general chef’s knife. The core is made of the finest Japanese carbon steel for unparalleled edge holding, and the blade’s distal tapering provides optimal balance and weight. A Makassar ebony handle and Pakkawood ferrules further classify this knife as a work of art. [8-1/4 inches, 193 grams]"
              imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SUsrjsPbRyOzjSJwtFl3?cache=true"
              price: '80.00'
            }
          ]
        }
        {
          title: 'Oishi Hammer'
          description: "Ohishi produces some of the finest-quality factory knives in the world, with stylized, ultra-thin blades that surpass most German and American handmade knives in both performance and beauty. At Ohishi, a small team of twenty-or-so blacksmiths and artisans design and forge knives with a characteristically thin blade geometry for clean cutting, and western-style riveted handles. The company, named after a small village at the foot of Mt Fuji where lavender grows rampant, set out to introduce high-performance knives at affordable prices, and they’ve done just that."
          imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/v5IsZcj3TFa3KmA6w0pB?cache=true"
          annotations: [
            {
              x: '30'
              y: '50'
              title: "Oishi Petty Knife"
              description: "This high-performance detail knife is made with the finest Japanese carbon steel for exceptional edge holding. The blade's hand-hammered surface helps release food from the knife when cutting. The octagonal ambidextrous handle is made of rich Makassar ebony with Pakkawood ferrules. [5-1/3 inches, 82 g]"
              imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/nmsJg1TpSmiClRMvNqvb?cache=true"
              price: '40.00'
            },
            {
              x: '10'
              y: '80'
              title: "Oishi Chef's Knife"
              description: "Modeled after the French chef’s blade but with all the grace and beauty of a Japanese handmade knife, this Gyuto is exceptionally versatile as a general chef’s knife. The core is made of the finest Japanese carbon steel for unparalleled edge holding, and the blade’s distal tapering provides optimal balance and weight. A Makassar ebony handle and Pakkawood ferrules further classify this knife as a work of art. [8-1/4 inches, 193 grams]"
              imageUrl: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SUsrjsPbRyOzjSJwtFl3?cache=true"
              price: '80.00'
            }
          ]
        }
      ]

      $scope.currentItem = $scope.collection[0]

      $scope.showcaseItems = []
      _.each $scope.collection, (collectionItem) ->
        showcaseItem = {}
        showcaseItem.title = collectionItem.title
        showcaseItem.description = collectionItem.description
        $scope.showcaseItems.push showcaseItem
        _.each collectionItem.annotations, (annotation) ->
          showcaseItem = {}
          showcaseItem.title = annotation.title
          showcaseItem.description = annotation.description
          showcaseItem.imageUrl = annotation.imageUrl
          $scope.showcaseItems.push showcaseItem

  link: (scope, element, attrs) ->
    console.log 'csShowcase!'

    angular.element($window).on 'scroll', (e) ->
      # console.log 'scroll event: ', e

  templateUrl: '/client_views/cs_showcase.html'

]