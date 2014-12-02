@app.directive 'csShowcase', ['$window', '$timeout', '$location', '$anchorScroll', '$routeParams', ($window, $timeout, $location, $anchorScroll, $routeParams) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ['$scope', ($scope) ->
    # $timeout ( ->
    #   $anchorScroll()
    # ), 1000

    if $scope.collectionName == 'knives'
      $scope.collection = [
        # INTRODUCTION
        {
          type: "title"
          title: "The ChefSteps Knives Collection"
          description: "There’s a reason that chefs and enthusiastic home cooks the world over are so smitten with Japanese knives. Lovingly crafted from the finest and most durable materials, these sexy, slender blades allow us to achieve perfectly sliced sashimi, delicate chiffonades, and meticulously diced meats and vegetables. Today, even the most famous European knifemakers have mostly abandoned hand-forging, yet the Japanese continue to offer extraordinary made-from-scratch tools, along with innovative hybrids that combine sturdy, factory-created handles with remarkably slender, hand-forged blades. The upshot is an instrument of uncommon beauty and elegance that’s still relatively affordable. Here you’ll find 10 knives that we use, and love, in our own kitchens. Whether you’re looking for an efficient little utility blade to go all day in the kitchen or a long, elegant chef’s knife to up your chopping game, you can’t go wrong with this collection of superior tools."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/knives-boxes-4.jpg"
        }
        # END INTRODUCTION
        # GYUTO KNIVES
        {
          id: "gyuto-knives"
          type: "title"
          title: "Gyuto Knives"
          description: "Modeled after the French pattern chef's knife, Gyutos are longer and slimmer than Santokus. The elongated blade makes this an ideal knife for creating the sawing motion necessary for cleanly cut meat, and it’s specially crafted to allow plenty of finger clearance—particularly helpful when you’re working over a cutting board."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Gyuto-all.jpg"
        }
        {
          id: "tadafusa-nashiji-gyuto"
          title: "Tadafusa Nashiji Gyuto"
          dimensions: "(210mm / 8&frac14in)"
          description: "We find ourselves returning time and again to this short, responsive knife—great when you need to work quickly or are looking for a versatile workhorse suitable for a full day of cooking."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Gyuto-Tadafusa-Nashiji.jpg"
          images: [
            "https://d92f495ogyf88.cloudfront.net/Knives-final/Tadafusa-Nashiji-close.jpg"
          ]
          price: "139.85"
          productId: 91019
          annotations: [
            {
              description: "Razor-sharp carbon steel blade"
              show: false
              position: {
                x: 58
                y: 39
              }
            }
            {
              description: "Secure ho wood handle"
              show: false
              position: {
                x: 28
                y: 62
              }
            }
          ]
        }
        {
          id: "ryusen-gyuto"
          title: "RyuSen Gyuto"
          dimensions: "(210mm / 8&frac14in)"
          description: "We love the beautiful steel polish on this relatively heavy knife, and also love knowing that its great looks will last a lifetime."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Gyuto-RyuSen.jpg"
          price: "198.00"
          productId: 696
          annotations: [
            {
              description: "Long, slim blade that’s perfect for preparing raw meats"
              show: false
              position: {
                x: 58
                y: 38
              }
            }
            {
              description: "Sturdy pakka wood handle for a great grip"
              show: false
              position: {
                x: 20
                y: 49
              }
            }
          ]
        }
        {
          id: "yoshikane-gyuto"
          title: "Yoshikane Gyuto"
          dimensions: "(210mm / 8&frac14in)"
          description: "This elegant all-purpose chef’s knife features a long, slim blade perfect for sawing meat and vegetables, with a subtly uneven surface that prevents food from sticking."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Gyuto-Yoshikane.jpg"
          price: "219.75"
          productId: 85673
          annotations: [
            {
              description: "A long, slim blade that’s perfect for meat preparation"
              show: false
              position: {
                x: 58
                y: 41
              }
            }
            {
              description: "Traditional ho wood blade"
              show: false
              position: {
                x: 20
                y: 50
              }
            }
          ]
        }
        # {
        #   id: "mutsumi-hinoura-gyuto"
        #   title: 'Mutsumi Hinoura Gyuto'
        #   dimensions: ""
        #   description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
        #   imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Gyuto-Mustumi-Hinoura.jpg"
        #   price: "279.00"
        #   productId: 92955
        # }
        # END GYUTO KNIVES
        # PETTY KNIVES
        {
          id: 'utility-petty-knives'
          type: "title"
          title: "Utility / Petty Knives"
          description: "Utility knives are excellent for tasks that require delicate slicing and a lot of dexterity. This workhorse will always come in handy when you need to slice up meats, vegetables, and fruit."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Petty-all.jpg"
        }
        {
          id: 'ryusen-utility-fruit-knife'
          title: "RyuSen Utility/Fruit Knife"
          dimensions: "(135mm / 5&#8531in)"
          description: "With a hand-forged steel blade, this utility knife is light and durable, just the way we like them. It’s also remarkably comfortable in-hand."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Petty-RyuSen.jpg"
          price: "116.95"
          productId: 801
          annotations: [
            {
              description: "Damascus-patterned blade with a stainless steel core"
              show: false
              position: {
                x: 58
                y: 41
              }
            }
            {
              description: "Sturdy pakka wood handle"
              show: false
              position: {
                x: 20
                y: 50
              }
            }
          ]
        }
        {
          id: 'tadafusa-nashiji-utility-fruit-knife'
          title: "Tadafusa Nashiji Utility/Fruit Knife"
          dimensions: "(135mm / 5&#8531in)"
          description: "An unbeatable value, this utility knife delivers in terms of weight and quality of materials, and feels great in hand. It’s a perfect tool for all those small prep tasks that are always coming up in the kitchen."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Petty-Tadafusa-Nashiji.jpg"
          price: "89.85"
          productId: 85680
          annotations: [
            {
              description: "Carbon steel blade designed to prevent food from sticking"
              show: false
              position: {
                x: 58
                y: 41
              }
            }
            {
              description: "Handle made from ho wood, a close relative of magnolia"
              show: false
              position: {
                x: 20
                y: 50
              }
            }
          ]
        }
        {
          id: 'yoshikane-petty-knife'
          title: "Yoshikane Petty Knife"
          dimensions: "(135mm / 5&#8531in)"
          description: "Best for detail slicing—think tomatoes and garlic—this utility knife by Yoshikane has a smooth, slender blade that slides easily through food."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Petty-Yoshikane.jpg"
          price: "143.95"
          productId: 86374
          annotations: [
            {
              description: "Rust-resistant blade made from SLD stainless steel (core) and stainless steel damascus (surface)"
              show: false
              position: {
                x: 58
                y: 45
              }
            }
            {
              description: "Durable handle designed for right-handers"
              show: false
              position: {
                x: 20
                y: 52
              }
            }
          ]
        }
        # END PETTY KNIVES
        # SANTOKU KNIVES
        {
          id: 'santoku-knives'
          type: "title"
          title: "Santoku Knives"
          description: "The traditional Japanese chef’s knife, these versatile choppers are now essential tools in well-equipped kitchens throughout the Western world as well."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Santoku-all-2.jpg"
        }
        {
          id: 'ryusen-santoku'
          title: "RyuSen Santoku"
          dimensions: "(170mm / 7in)"
          description: "A great gift for new cooks looking to improve their knife skills, this versatile model is durable and safe—perfect for practicing vegetable-slicing skills."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Santoku-RyuSen.jpg"
          price: "174.50"
          productId: 687
          annotations: [
            {
              description: "Stainless steel blade designed for multipurpose chopping"
              show: false
              position: {
                x: 58
                y: 34
              }
            }
            {
              description: "Comfortable pakka wood handle"
              show: false
              position: {
                x: 20
                y: 51
              }
            }
          ]
        }
        {
          id: 'tadafusa-nashiji-santoku'
          title: "Tadafusa Nashiji Santoku"
          dimensions: "(170mm / 6&frac34in)"
          description: "With this very fairly priced, razor-sharp Santoku you’ll easily achieve super-skinny slices of onions and other vegetables. The raw ho wood handle offers a great grip so you can work full speed ahead with zero fear of slipping."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Santoku-Tadafusa-Nashiji.jpg"
          price: "99.85"
          productId: 85681
          annotations: [
            {
              description: "A versatile carbon steel blade"
              show: false
              position: {
                x: 58
                y: 42
              }
            }
            {
              description: "Comfortable, oval-shaped handle"
              show: false
              position: {
                x: 20
                y: 52
              }
            }
          ]
        }
        {
          id: 'yoshikane-santoku'
          title: "Yoshikane Santoku"
          dimensions: "(180mm / 7&#8539in)"
          description: "A multipurpose, rust-resistant chopper, this knife boasts a beautiful, hand-hammered surface and a comfortable handles made from Ho wood with buffalo horn ferrule."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Santoku-Yoshikane.jpg"
          price: "179.95"
          productId: 91653
          annotations: [
            {
              description: "Hand-hammered blade surface means food won’t stick while you chop"
              show: false
              position: {
                x: 58
                y: 42
              }
            }
            {
              description: "Ho wood handle with buffalo horn ferrule"
              show: false
              position: {
                x: 20
                y: 52
              }
            }
          ]
        }
        # END SANTOKU KNIVES
        # SUJIHIKI KNIVES
        {
          id: 'sujihiki-knives'
          type: "title"
          title: "Sujihiki Knives"
          description: "It takes a very precise knife to create perfect sushi and sashimi. With a thin, long blade that ensures a remarkably clean cut, these extremely sharp carving knives are well suited for slicing and portioning meats and fish."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Sujihiki-Ryusen-close-up.jpg"
        }
        {
          id: 'ryusen-sujihiki'
          title: "RyuSen Sujihiki"
          dimensions: "(270mm / 10&frac34in)"
          description: "Heavy, with a Pakkawood handle designed for the long haul, this sexy 16-incher will level up your slicing skills, helping you achieve perfect straight cuts."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-final/Sujihiki-Ryusen-2.jpg"
          price: "309.50"
          productId: 83501
          annotations: [
            {
              description: "A sharp stainless steel blade for precision slicing"
              show: false
              position: {
                x: 58
                y: 41
              }
            }
            {
              description: "Handle made from multiple layers of wood impregnated with resin"
              show: false
              position: {
                x: 20
                y: 54
              }
            }
          ]
        }
        # END SUJIHIKI KNIVES
      ]

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
      console.log "SOCIAL URL: ", window.location.href
      window.location.href

    $scope.socialTitle = ->
      ""

    $scope.socialMediaItem = ->
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/bIBHqoDWR3eLBtF8lQgu/convert?fit=crop&w=800&cache=true"

    $scope.tweetMessage = ->
      "I really want the #{$scope.currentItem.title} from #{$scope.collection[0].title} #{window.location}"

    $scope.toggleAnnotation = (annotation) ->

      annotation.show = !annotation.show
      console.log 'TOGGLING ANNOTATION: ', annotation

    $scope.itemClass = (item) ->
      console.log 'item type is: ', item.type
      if item.type == 'title'
        return 'cs-showcase-item-title'
      else
        return 'cs-showcase-item-standard'

    # updateCurrent: (item, progress) ->
    #   if $scope.currentItem != item
    #     $scope.showcaseCurrentClass = 'direction-' + $scope.direction
    #     $scope.$apply()
    #     $timeout ( ->
    #       $scope.currentItem = item
    #       # console.log 'currentItem is: ', $scope.currentItem
    #       # console.log 'updating Current with: ', $scope.direction
    #       $scope.showcaseCurrentClass = ''

    #       # Set the location has so anchorscrolling works
    #       # if item.id
    #       #   $location.path('/item')
    #       #   $location.hash(item.id)
    #       # else
    #       #   $location.path('')
    #       #   $location.hash('')
    #       $scope.$apply()
    #     ), 100

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
        # csShowcaseController.updateCurrent(scope.csShowcaseItem, progress)
        element.addClass('active')
      else
        element.removeClass('active')

    windowElement.on 'scroll', (e) ->
      # handleScroll(e)
      _.throttle(handleScroll(e), 100)

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