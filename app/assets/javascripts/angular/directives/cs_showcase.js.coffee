@app.directive 'csShowcase', ['$window', ($window) ->
  restrict: 'A'
  scope: {
    collection: '@'
  }
  controller: ($scope) ->
    if $scope.collection == 'knives'
      $scope.items = [
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
              images: [
                "https://d3awvtnmmsvyot.cloudfront.net/api/file/nmsJg1TpSmiClRMvNqvb?cache=true"
              ]
              price: '40.00'
            },
            {
              x: '10'
              y: '80'
              title: "Asai Chef's Knife"
              description: "Modeled after the French chef’s blade but with all the grace and beauty of a Japanese handmade knife, this Gyuto is exceptionally versatile as a general chef’s knife. The core is made of the finest Japanese carbon steel for unparalleled edge holding, and the blade’s distal tapering provides optimal balance and weight. A Makassar ebony handle and Pakkawood ferrules further classify this knife as a work of art. [8-1/4 inches, 193 grams]"
              images: [
                "https://d3awvtnmmsvyot.cloudfront.net/api/file/SUsrjsPbRyOzjSJwtFl3?cache=true"
                "https://d3awvtnmmsvyot.cloudfront.net/api/file/huVmTeBRsGbvPFij4bVQ?cache=true"
              ]
              price: '80.00'
            }
          ]
        }
      ]

      $scope.currentItem = $scope.items[0]
  link: (scope, element, attrs) ->
    console.log 'csShowcase!'

  templateUrl: '/client_views/cs_showcase.html'

]