angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", "$timeout", ($scope, $http, $timeout) ->

  $scope.state = "white"

  $scope.inputs = 
    water_temp: 70
    perceptual_yolk_viscosity: 3
    diameter: 43
    start_temp: 5
    surface_heat_transfer_coeff: 135
    beta: 1.7

  $scope.formatTime = (t, showSeconds = true) ->

    h = Math.floor(t / 3600)
    t = t - (h * 3600)
    m = Math.floor(t / 60)
    t = t - (m * 60)
    s = Math.floor(t)
    m += 1 if (s >= 30) && (! showSeconds)

    # Three cases:
    #
    # (1) 6h 1m
    if h > 0
      result = "#{h}h #{m}m"

    # (2) 7m 2s
    else if showSeconds
      # Force a non-zero second so user knows we need precision
      s = 1 if s == 0       
      result = "#{m}m #{s}s"

    # (3) 43 mins
    else
      result = "#{m} min"

    result

  $scope.needsSeconds = ->
    ($scope.output?.items?[2] - $scope.output?.items?[0]) < 90 

  $scope.perceptualYolkDescriptor = (x) ->
    descrips = [  
      "evaporated milk",
      "maple syrup",
      "chocolate syrup",
      "molasses",
      "sweetened condensed milk",
      "ready-to-eat pudding",
      "ready-to-eat icing"
    ] 
    descrips[Math.round(x - 1)]

  $scope.yolkImages = (x) ->
    images = [
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/NFDyyufQSaCx4OTqTS1n/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/g2hLw1KToCAmBLRILwNP/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/xqeQQvwRSGSdHEkU2du5/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/TIePI4PTCWEHGwPxWBpT/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/lxpXnhiIQaUlUa1DDVFQ/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/lxpXnhiIQaUlUa1DDVFQ/convert?fit=max&w=670&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/GynsRsomRtmBujrLTvJE/convert?fit=max&w=670&cache=true"
    ]
    images[Math.round(x - 1)]

  $scope.update = ->
    $scope.loading = true
    $http.get("http://gentle-taiga-4435.herokuapp.com/egg_time/", params: $scope.inputs).success((data, status) ->
      $scope.output = data
      $scope.loading = false
      $scope.$apply() if ! $scope.$$phase
      console.log(data.items[1])
    ).error((data, status, headers, config) ->
      debugger
    )

  $scope.throttledUpdate = 
    _.throttle($scope.update, 250)

  $scope.$watchCollection 'inputs', -> 
    $scope.inputs.desired_viscosity = Math.exp(-1.6 + (0.704 * $scope.inputs.perceptual_yolk_viscosity))
    $scope.throttledUpdate()

  $scope.goState = (name) ->
    $scope.state = name

  # Social share callbacks
  $scope.socialURL = ->
    "http://chefsteps.com/egg_timer"

  $scope.socialTitle = ->
    ""

  $scope.socialMediaItem = ->
    "https://d3awvtnmmsvyot.cloudfront.net/api/file/bIBHqoDWR3eLBtF8lQgu/convert?fit=crop&w=800&cache=true"

  $scope.tweetMessage = ->
    "Egg calculator says #{$scope.formatTime($scope.output.items[4], $scope.needsSeconds())} at #{$scope.inputs.water_temp} %C2%B0C for my perfect sous vide egg"

  $scope.emailSubject = ->
    "Sous vide egg calculator"

  $scope.emailBody = ->
    "Hey, I thought you might dig the sous vide egg calculator at ChefSteps.com. Here's the link: " + $scope.socialURL()

  $scope.oneDecimal = (x) ->
    Math.round(x * 10) / 10


]
