angular.module('ChefStepsApp').service 'csFtue', ['$rootScope', 'csIntent', ($rootScope, csIntent) ->
  # First Time User Experience Flow
  # This array sets the sequence of modals to be opened when the intent is set to 'ftue'
  csFtue = {}

  csFtue.items = [
    {
      name: 'Survey'
      title: 'How do you cook?'
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
    $rootScope.$emit methodName, {intent: 'ftue'}

  csFtue.start = ->
    # Open the first item
    name = csFtue.items[0].name
    csFtue.open(name)

  csFtue.end = ->
    # Close the current item and clear the intent
    $rootScope.$emit 'close' + csFtue.current.name + 'FromFtue'
    csIntent.clearIntent()

  csFtue.indexOfItem = (item) ->
    value = {}
    angular.forEach csFtue.items, (ftueItem, index) ->
      if ftueItem['name'] == item['name']
        value = index
    return value

  return csFtue
]

@app.controller 'FtueController', [ '$scope', 'csFtue', 'csIntent', ($scope, csFtue, csIntent) ->

  $scope.start = ->
    csIntent.setIntent('ftue')
    csFtue.open('Survey')

]