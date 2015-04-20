angular.module('ChefStepsApp').service 'csFtue', ['$rootScope', 'csIntent', 'csAuthentication', '$modal', ($rootScope, csIntent, csAuthentication, $modal) ->
  # First Time User Experience Flow
  # This array sets the sequence of modals to be opened when the intent is set to 'ftue'
  csFtue = {}
  
  csFtue.start = ->
    modalInstance = $modal.open(
      templateUrl: "/client_views/_ftue.html"
      backdrop: false
      keyboard: false
      windowClass: "modal-fullscreen"
      controller: 'FtueController'
    )

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

@app.controller 'FtueController', [ '$scope', '$modalInstance', '$rootScope', 'csAuthentication', ($scope, $modalInstance, $rootScope, csAuthentication) ->
  $scope.items = [
    {
      name: 'Survey'
      title: 'What kinds of things are you most interested in?'
    }
    # {
    #   name: 'Connect'
    #   title: 'Connect Your Social Networks'
    # }
    # {
    #   name: 'Invite'
    #   title: 'Invite your friends'
    # }
    {
      name: 'Recommendations'
      title: 'Get Started'
    }
  ]

  $scope.prev = ->
    # If there is a previous item, close the current item and open the previous one
    item = $scope.items[$scope.currentIndex - 1]
    if item
      $rootScope.$emit 'close' + $scope.current.name + 'FromFtue'
      $scope.open(item.name)

  $scope.next = ->
    # If there is a next item, close the current item and open the next one
    item = $scope.items[$scope.currentIndex + 1]
    if item
      $rootScope.$emit 'close' + $scope.current.name + 'FromFtue'
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