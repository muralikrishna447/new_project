angular.module('ChefStepsApp').service 'csFtue', ['$rootScope', 'csIntent', 'csAuthentication', ($rootScope, csIntent, csAuthentication) ->
  # First Time User Experience Flow
  # This array sets the sequence of modals to be opened when the intent is set to 'ftue'
  csFtue = {}

  csFtue.items = [
    {
      name: 'Survey'
      title: 'How do you cook?'
    }
    {
      name: 'Connect'
      title: 'Connect Your Social Networks'
    }
    {
      name: 'Invite'
      title: 'Invite your friends'
    }
    {
      name: 'Recommendations'
      title: 'Get Started'
    }
    {
      name: 'Welcome'
      title: 'Welcome to ChefSteps!'
    }
  ]

  csFtue.prev = ->
    # If there is a previous item, close the current item and open the previous one
    item = csFtue.items[csFtue.currentIndex - 1]
    if item
      $rootScope.$emit 'close' + csFtue.current.name + 'FromFtue'
      csFtue.open(item.name)

  csFtue.next = ->
    # If there is a next item, close the current item and open the next one
    item = csFtue.items[csFtue.currentIndex + 1]
    if item
      $rootScope.$emit 'close' + csFtue.current.name + 'FromFtue'
      csFtue.open(item.name)
    else
      csFtue.end()

  csFtue.open = (name) ->
    csFtue.current = _.where(csFtue.items, {name: name})[0]
    csFtue.currentIndex = csFtue.indexOfItem(csFtue.current)
    methodName = 'open' + name
    console.log "emtting", methodName
    $rootScope.$emit methodName, {intent: 'ftue'}

  csFtue.start = ->
    # Open the first item
    name = csFtue.items[0].name
    csFtue.open(name)

  csFtue.end = ->
    # Close the current item and clear the intent
    $rootScope.$emit 'close' + csFtue.current.name + 'FromFtue'
    csIntent.clearIntent()
    userProfilePath = '/profiles/' + csAuthentication.currentUser().slug
    console.log userProfilePath
    window.location.href = userProfilePath

  csFtue.indexOfItem = (item) ->
    value = {}
    angular.forEach csFtue.items, (ftueItem, index) ->
      if ftueItem['name'] == item['name']
        value = index
    return value

  return csFtue
]

@app.controller 'FtueModalController', [ '$scope', '$modal', ($scope, $modal) ->

  $scope.start = ->
    # csIntent.setIntent('ftue')
    modalInstance = $modal.open(
      templateUrl: "/client_views/_ftue.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      controller: 'FtueController'
    )
    # csFtue.open('Survey')

]

@app.controller 'FtueController', [ '$scope', '$modalInstance', 'csAuthentication', ($scope, $modalInstance, csAuthentication) ->
  $scope.items = [
    {
      name: 'Survey'
      title: 'How do you cook?'
    }
    {
      name: 'Connect'
      title: 'Connect Your Social Networks'
    }
    {
      name: 'Invite'
      title: 'Invite your friends'
    }
    {
      name: 'Recommendations'
      title: 'Get Started'
    }
  ]

  $scope.prev = ->
    # If there is a previous item, close the current item and open the previous one
    item = $scope.items[$scope.currentIndex - 1]
    if item
      # $rootScope.$emit 'close' + $scope.current.name + 'FromFtue'
      $scope.open(item.name)

  $scope.next = ->
    # If there is a next item, close the current item and open the next one
    item = $scope.items[$scope.currentIndex + 1]
    if item
      # $rootScope.$emit 'close' + $scope.current.name + 'FromFtue'
      $scope.open(item.name)
    else
      $scope.end()

  $scope.open = (name) ->
    $scope.current = _.where($scope.items, {name: name})[0]
    $scope.currentIndex = $scope.indexOfItem($scope.current)

  $scope.start = ->
    # Open the first item
    name = $scope.items[0].name
    $scope.open(name)

  $scope.end = ->
    # Close the current item and clear the intent
    # $rootScope.$emit 'close' + $scope.current.name + 'FromFtue'
    $modalInstance.close()
    # csIntent.clearIntent()
    userProfilePath = '/profiles/' + csAuthentication.currentUser().slug

  $scope.indexOfItem = (item) ->
    value = {}
    angular.forEach $scope.items, (ftueItem, index) ->
      if ftueItem['name'] == item['name']
        value = index
    return value

  $scope.currentNumber = ->
    $scope.currentIndex + 1

  $scope.ftueLength = ->
    $scope.items.length

  $scope.showPrev = ->
    true if $scope.currentIndex > 0

  $scope.showNext = ->
    true if $scope.currentNumber() < $scope.ftueLength()

  $scope.start()

]