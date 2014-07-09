angular.module('ChefStepsApp').service 'csIntent', ['$rootScope', ($rootScope) ->
  this.intent = {}

  this.setIntent = (intent) ->
    this.intent = intent
    $rootScope.$emit 'intentChanged'

  this.clearIntent = ->
    this.intent = {}
    $rootScope.$emit 'intentChanged'

  this.getIntent = ->
    this.intent

  this
]