@app.directive 'csShowcase', ['$window', '$timeout', ($window, $timeout) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ['$scope', ($scope) ->
    if $scope.collectionName == 'knives'
      $scope.collection = [
        # INTRODUCTION
        {
          title: "The ChefSteps Knives Collection"
          description: "There’s a reason that chefs and enthusiastic home cooks the world over are so smitten with Japanese knives. Lovingly crafted from the finest and most durable materials, these sexy, slender blades allow us to achieve perfectly sliced sashimi, delicate chiffonades, and meticulously diced meats and vegetables. Today, even the most famous European knifemakers have mostly abandoned hand-forging, yet the Japanese continue to offer extraordinary made-from-scratch tools, along with innovative hybrids that combine sturdy, factory-created handles with remarkably slender, hand-forged blades. The upshot is an instrument of uncommon beauty and elegance that’s still relatively affordable. Here you’ll find 10 knives that we use, and love, in our own kitchens. Whether you’re looking for an efficient little utility blade to go all day in the kitchen or a long, elegant chef’s knife to up your chopping game, you can’t go wrong with this collection of superior tools."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Knives-boxes-5.jpg"
        }
        # END INTRODUCTION
        # GYUTO KNIVES
        {
          title: "Gyuto Knives"
          description: "Modeled after the French pattern chef's knife, Gyutos are longer and slimmer than Santokus. The elongated blade makes this an ideal knife for creating the sawing motion necessary for cleanly cut meat, and it’s specially crafted to allow plenty of finger clearance—particularly helpful when you’re working over a cutting board."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Knives-boxes-7.jpg"
        }
        {
          title: "Tadafusa Nashiji Gyuto (210mm / 8&frac14in)"
          description: "We find ourselves returning time and again to this short, responsive knife—great when you need to work quickly or are looking for a versatile workhorse suitable for a full day of cooking."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-Gyuto.jpg"
          images: [
            "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-close.jpg"
          ]
          price: "139.85"
          productId: 91019
          annotations: [
            {
              type: 'right'
              title: 'Tadafusa Nashiji Gyuto'
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
              position: {
                x: 58
                y: 38
              }
            }
          ]
        }
        {
          title: "RyuSen Gyuto (210mm / 8&frac14in)"
          description: "We love the beautiful steel polish on this relatively heavy knife, and also love knowing that its great looks will last a lifetime."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/RyuSen-Gyuto.jpg"
          price: "198.00"
          productId: 696
          annotations: [
            {
              type: 'right'
              title: 'RyuSen Gyuto'
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
              position: {
                x: 58
                y: 42
              }
            }
          ]
        }
        {
          title: 'Mutsumi Hinoura Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Mutsumi-Hinoura-Gyuto-2.jpg"
          price: "279.00"
          productId: 92955
        }
        # END GYUTO KNIVES
        # PETTY KNIVES
        {
          title: "Utility / Petty Knives"
          description: "Utility knives are excellent for tasks that require delicate slicing and a lot of dexterity. This workhorse will always come in handy when you need to slice up meats, vegetables, and fruit."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Knives-boxes-2.jpg"
        }
        {
          title: "RyuSen Utility/Fruit (135mm / 5&frac12in)"
          description: "With a hand-forged, Damascus-patterned stainless steel blade and a pakkawood handle, this utility knife is light and durable, just the way we like them. It’s also remarkably comfortable in-hand."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/RyuSen-close.jpg"
          price: "116.95"
          productId: 801
        }
        {
          title: "Tadafusa Nashiji Utility/Fruit (135mm / 5&frac12in)"
          description: "An unbeatable value, this utility knife delivers in terms of weight and quality of materials, and feels great in hand. It’s a perfect tool for all those small prep tasks that are always coming up in the kitchen."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-petty.jpg"
          price: "89.85"
          productId: 85680
        }
        # END PETTY KNIVES
        # SANTOKU KNIVES
        {
          title: "Santoku Knives"
          description: "The traditional Japanese chef’s knife, these versatile choppers are now essential tools in well-equipped kitchens throughout the Western world as well."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Santoku-all-3.jpg"
        }
        {
          title: "RyuSen Santuku (170mm / 7in)"
          description: "A great gift for new cooks looking to improve their knife skills, this versatile model is durable and safe—perfect for practicing vegetable-slicing skills."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/RyuSen-Santoku.jpg"
          price: "174.50"
          productId: 687
        }
        {
          title: "Tadafusa Nashiji Santoku (170mm / 6&frac34in)"
          description: "With this very fairly priced, razor-sharp Santoku you’ll easily achieve super-skinny slices of onions and other vegetables. The raw ho wood handle offers a great grip so you can work full speed ahead with zero fear of slipping."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-Santoku.jpg"
          price: "99.85"
          productId: 85681
        }
        # END SANTOKU KNIVES
        # SUJIHIKI KNIVES
        {
          title: "Sujihiki Knives"
          description: "It takes a very precise knife to create perfect sushi and sashimi. With a thin, long blade that ensures a remarkably clean cut, these extremely sharp carving knives are well suited for slicing and portioning meats and fish."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Knives-boxes.jpg"
        }
        {
          title: "RyuSen Sujihiki (270mm / 10&frac34in)"
          description: "Heavy, with a Pakkawood handle designed for the long haul, this sexy 16-incher will level up your slicing skills, helping you achieve perfect straight cuts."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Ryusen-sujihiki-4.jpg"
          price: "309.50"
          productId: 83501
        }
        # END SUJIHIKI KNIVES
      ]

    $scope.annotationLineStyle = (annotation) ->
      lineHeight = 20 # Percent
      annotationWidth = 30
      {
        top: lineHeight + '%'
        left: annotation.position.x + '%'
        height: annotation.position.y - lineHeight + '%'
        width: 100 - annotationWidth - annotation.position.x + '%'
      }

    $scope.annotationDotStyle = (annotation) ->
      {
        top: annotation.position.y + '%'
        left: annotation.position.x + '%'
      }

    $scope.buyNowUrl = (item) ->
      productId = item.productId
      url = "http://www.epicedge.com/shopaff.asp?affid=1&id=#{productId}"
      console.log 'the buy now url is: ', url
      return url

    $scope.currentItem = $scope.collection[0]

    updateCurrent: (item, progress) ->
      if $scope.currentItem != item
        $scope.showcaseCurrentClass = 'direction-' + $scope.direction
        $scope.$apply()
        $timeout ( ->
          $scope.currentItem = item
          console.log 'currentItem is: ', $scope.currentItem
          console.log 'updating Current with: ', $scope.direction
          $scope.showcaseCurrentClass = ''
          $scope.$apply()
        ), 300

  ]

  link: (scope, element, attrs) ->
    oldPosition = 0
    windowElement = angular.element($window)
    windowElement.on 'scroll', (e) ->
      position = windowElement.scrollTop()
      # console.log 'WINDOW POSITION: ', position
      if oldPosition
        diff = oldPosition - position
        if diff > 0
          # console.log 'SCROLLING UP'
          scope.direction = 'up'
        else
          # console.log 'SCROLLING DOWN'
          scope.direction = 'down'
      # console.log 'oldPosition: ', oldPosition
      oldPosition = position



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

    windowElement.on 'scroll', (e) ->
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
        completed = position - start
        progress = completed/height*100
        csShowcaseController.updateCurrent(scope.csShowcaseItem, progress)

]

@app.directive 'csShowcaseImage', [ ->
  restrict: 'A'
  replace: true
  scope: {
    csShowcaseImage: '='
  }

  link: (scope, element, attrs) ->
    # console.log 'scope: ', scope
    # console.log 'image element: ', element[0].clientHeight

    element.on 'load', (e) ->
      # console.log 'LOADED: ', e
      # console.log 'element: ', element
      height = element[0].height
      scope.csShowcaseImage.imageHeight = height

  template:
    """
      <img src="{{csShowcaseImage.imageUrl}}"/>
    """
]