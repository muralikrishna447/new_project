angular.module('ChefStepsApp').controller 'EggTimerController', ["$scope", "$http", "csEggCalculatorService", "csUtilities", "$sce", ($scope, $http, csEggCalculatorService, csUtilities, $sce) ->

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



  $scope.yolkVideos =
    [
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_20min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_25min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_30min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_35min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_45min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_60min.mp4",
      "https://s3.amazonaws.com/chefsteps/egg_timer_videos/yolk_63_105min.mp4",
    ]

  $scope.whiteVideos =
    [
      {temp: 60, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_60_60min.mp4"}
      {temp: 61, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_61_60min.mp4"}
      {temp: 62, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_62_60min.mp4"}
      {temp: 63, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_63_60min.mp4"}
      {temp: 64, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_64_60min.mp4"}
      {temp: 65, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_65_60min.mp4"}
      {temp: 66, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_66_60min.mp4"}
      {temp: 67, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_67_60min.mp4"}
      {temp: 69, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_69_60min.mp4"}
      {temp: 70, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_70_60min.mp4"}
      {temp: 71, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_71_60min.mp4"}
      {temp: 72, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_72_60min.mp4"}
      {temp: 75, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_75_60min.mp4"}
      {temp: 85, video: "https://s3.amazonaws.com/chefsteps/egg_timer_videos/white_85_60min.mp4"}
    ]

  $scope.trustedVideo = (video) ->
    $sce.trustAsResourceUrl(video)


  $scope.update = ->
    params =
      desired_viscosity: Math.exp(-1.6 + (0.704 * $scope.inputs.perceptual_yolk_viscosity))
      water_temp: $scope.whiteVideos[Math.round($scope.inputs.perceptual_white_viscosity)].temp
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

  $scope.incrementWhite = (increment) ->
    pwv = parseInt($scope.inputs.perceptual_white_viscosity)
    $scope.inputs.perceptual_white_viscosity = Math.max(Math.min(pwv + increment, 13), 0)

  $scope.incrementYolk= (increment) ->
    pyv = parseInt($scope.inputs.perceptual_yolk_viscosity)
    $scope.inputs.perceptual_yolk_viscosity = Math.max(Math.min(pyv + increment, 7), 1)
    
  # Social share callbacks
  $scope.socialURL = ->
    window.location.href

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