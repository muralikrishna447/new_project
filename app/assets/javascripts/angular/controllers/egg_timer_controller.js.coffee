angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", "csEggCalculatorService", "csUtilities", ($scope, $http, csEggCalculatorService, csUtilities) ->

  $scope.eggService = csEggCalculatorService
  $scope.utils = csUtilities

  $scope.visitedStates = []

  $scope.inputs =
    state: "white"
    perceptual_white_viscosity: 3
    perceptual_yolk_viscosity: 3
    circumference: 135
    start_temp: 5
    surface_heat_transfer_coeff: 135
    units: 'c'



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

  $scope.yolkImages =
    [
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/NFDyyufQSaCx4OTqTS1n/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/g2hLw1KToCAmBLRILwNP/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/xqeQQvwRSGSdHEkU2du5/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/TIePI4PTCWEHGwPxWBpT/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/lxpXnhiIQaUlUa1DDVFQ/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/5vzqnpRBQC6gbYX7gI85/convert?fit=max&w=320&cache=true",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/GynsRsomRtmBujrLTvJE/convert?fit=max&w=320&cache=true"
    ]

  $scope.whiteImages =
    [
      {temp: 60, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/eEbaYrmfTyahirkQZmFd/convert?fit=max&w=320&cache=true"}
      {temp: 61, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/vgOyRiCSTzGnQ4dUCpFj/convert?fit=max&w=320&cache=true"}
      {temp: 62, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fZPCpQohTlGHeSWUipv0/convert?fit=max&w=320&cache=true"}
      {temp: 63, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6z6F36qBT4WybDaZp5Sy/convert?fit=max&w=320&cache=true"}
      {temp: 64, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/QKeQCuJRISx5klbFyyTS/convert?fit=max&w=320&cache=true"}
      {temp: 65, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/uTexSIQ4Qce4y2hxVoDN/convert?fit=max&w=320&cache=true"}
      {temp: 66, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/WIm6HQWPRwCz93Kl7a6s/convert?fit=max&w=320&cache=true"}
      {temp: 67, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/BhXtmLcKTv6Q8Y8lHzrJ/convert?fit=max&w=320&cache=true"}
      {temp: 69, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/2t7XhKLOQOs3QMqQhjIr/convert?fit=max&w=320&cache=true"}
      {temp: 70, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/2QynNcTtSi6SRNKEMV73/convert?fit=max&w=320&cache=true"}
      {temp: 71, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fmymXbNS0WPmzJMznCwd/convert?fit=max&w=320&cache=true"}
      {temp: 72, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6uDEuuTnKvRSHQ75VXOw/convert?fit=max&w=320&cache=true"}
      {temp: 75, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/psBbjxLNTkaLhVuRMtUL/convert?fit=max&w=320&cache=true"}
      {temp: 85, image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/yPpKhnStRemAG8CfM0hw/convert?fit=max&w=320&cache=true"}
    ]


  $scope.update = ->
    params =
      desired_viscosity: Math.exp(-1.6 + (0.704 * $scope.inputs.perceptual_yolk_viscosity))
      water_temp: $scope.whiteImages[Math.round($scope.inputs.perceptual_white_viscosity)].temp
      diameter: $scope.inputs.circumference / Math.PI
      start_temp: $scope.inputs.start_temp
      surface_heat_transfer_coeff: $scope.inputs.surface_heat_transfer_coeff
      beta: 1.7

    $scope.water_temp = params.water_temp

    $scope.loading = true
    $http.get("http://gentle-taiga-4435.herokuapp.com/egg_time/", params: params).success((data, status) ->
      $scope.output = data
      $scope.loading = false
      $scope.$apply() if ! $scope.$$phase
      mixpanel.track('Egg Calculated', angular.extend({},  $scope.inputs, {water_temp: $scope.water_temp}, $scope.output))
      mixpanel.people.increment('Egg Calculated')

    ).error((data, status, headers, config) ->
      debugger
    )

  $scope.goState = (name) ->
    $scope.inputs.state = name
    if name == "white"
      $scope.visitedStates = []
    else
      $scope.visitedStates.push name
    if name == "results"
      $scope.update()
    mixpanel.track('Egg Calculator Page', {'state' : name})

  $scope.stateVisited = (name) ->
    "visited" if $scope.visitedStates.indexOf(name) >= 0

  # Social share callbacks
  $scope.socialURL = ->
    "http://chefsteps.com/egg_timer"

  $scope.socialTitle = ->
    ""

  $scope.socialMediaItem = ->
    "https://d3awvtnmmsvyot.cloudfront.net/api/file/bIBHqoDWR3eLBtF8lQgu/convert?fit=crop&w=800&cache=true"

  $scope.tweetMessage = ->
    if $scope.inputs.units == "c"
      "Egg calculator says #{$scope.utils.formatTime($scope.output.items[4], $scope.needsSeconds())} at #{$scope.water_temp} %C2%B0C for my perfect sous vide egg"
    else
      "Egg calculator says #{$scope.utils.formatTime($scope.output.items[4], $scope.needsSeconds())} at #{$scope.utils.cToF($scope.water_temp)} %C2%B0F for my perfect sous vide egg"


  $scope.emailSubject = ->
    "Sous vide egg calculator"

  $scope.emailBody = ->
    "Hey, I thought you might dig the sous vide egg calculator at ChefSteps.com. Here's the link: " + $scope.socialURL()

  $scope.oneDecimal = (x) ->
    Math.round(x * 10) / 10

  $scope.toggleShowSettings = (event) ->
    if event.altKey
      $scope.easterEgg = ! $scope.easterEgg
    else
      $scope.showSettings = ! $scope.showSettings

  # To get started; makes sure we get our mixpanel track
  $scope.goState('white')


]