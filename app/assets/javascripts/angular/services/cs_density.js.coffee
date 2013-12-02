angular.module('ChefStepsApp').service 'csDensityService', [ ()  ->

  this.densityUnits =
    [
      {name: 'Tablespoon', perL: 67.628},
      {name: 'Cup', perL: 4.22675},
      {name: 'Liter',  perL: 1}
    ]

  this.displayDensity = (x) ->
    if x then window.roundSensible(x) else "Set..."

  this.displayDensityNoSet = (x) ->
    if x && _.isNumber(x) then window.roundSensible(x) else ""

  this.editDensity = (ingredient) ->
    this.densityIngredient = ingredient

]
