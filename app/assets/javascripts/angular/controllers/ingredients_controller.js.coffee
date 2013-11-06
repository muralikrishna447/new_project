angular.module('ChefStepsApp').controller 'IngredientsController', ["$scope", "$rootScope", "$timeout", "$http", "limitToFilter", ($scope, $rootScope, $timeout, $http, limitToFilter) ->

  $scope.shouldShowMasterIngredientsRemovedModal = false
  $scope.showIngredientsMenu = false

  $scope.getAllUnits = ->
    window.allUnits

  $scope.ingredient_display_type = (ai) ->
    result = "basic"
    if ai?.ingredient?
      result = "product" if !! ai.ingredient.product_url
      result = "subrecipe" if !! ai.ingredient.sub_activity_id
      result = "fake_link" if $scope.editMode && (result == "product" || result == "subrecipe")
    result

  $scope.unitMultiplier = (unit_name) ->
    result = 1
    result = 1000 if unit_name == "kg"
    result

  $scope.addIngredient =  ->
    # Don't set an ingredient object within the item or you'll screw up the typeahead and not get your placeholder
    # but an ugly [object Object]
    item = {unit: "g", quantity: "0"}
    $scope.getIngredientsList().push(item)
    #$scope.addUndo()

  $scope.removeIngredient = (index) ->
    $scope.getIngredientsList().splice(index, 1)
    $scope.addUndo()

  $scope.all_ingredients = (term) ->
    s = ChefSteps.splitIngredient(term)
    $http.get("/ingredients.json?limit=15&include_sub_activities=true&search_title=" + s["ingredient"]).then (response) ->
      r = response.data
      for i in r
        i.title += " [RECIPE]" if i.sub_activity_id?
      # always include current search text as an option, first!
      r = _.sortBy(r, (i) -> i.title != s["ingredient"])
      r.unshift({title: s["ingredient"]}) if s["ingredient"]? && !_.find(r, (i) -> i.title == s["ingredient"])
      r

  $scope.matchableIngredients = (i1, i2) ->
    # Use title, not id b/c new ingredients not saved yet don't have an id
    (i1.ingredient.title == i2.ingredient.title) &&
    ((i1.note || "") == (i2.note || "")) &&
    (i1.unit == i2.unit)

  $scope.hasAnyStepIngredients = ->
    if $scope.activity?.steps
      for step in $scope.activity.steps
        return true if step.ingredients.length > 0
    false

  $scope.fillMasterIngredientsFromSteps = ->
    old_count = $scope.activity.ingredients.length
    $scope.activity.ingredients = []

    for step in $scope.activity.steps
      for si in step.ingredients
        ing = _.find($scope.activity.ingredients, (ai) -> $scope.matchableIngredients(ai, si))
        if ing?
          if ing.unit != "a/n"
            ing.display_quantity = parseFloat(ing.display_quantity) + parseFloat(si.display_quantity)
        else
          $scope.activity.ingredients.push(deepCopy(si))
    $scope.addUndo()
    $scope.temporaryNoAutofocus()
    if $scope.activity.ingredients.length < old_count
      $scope.shouldShowMasterIngredientsRemovedModal = true

  $scope.loadSubrecipe = (id) ->
    window.location.href = '/activities/' + id unless $scope.overrideLoadActivity?(id) 

  $scope.displayScaling = ->
    Math.round($rootScope.csScaling * 10) / 10

  lastCustomScale = 1
  baseScales = [0.5, 1, 1.5, 2, 3, 4]

  $scope.cycleScaling = ->
    lastCustomScale = $scope.displayScaling() if _.indexOf(baseScales, $scope.displayScaling()) < 0
    scales = _.uniq(_.sortBy(_.union(baseScales, [lastCustomScale]), (x) -> x))
    idx = _.indexOf(scales, $scope.displayScaling(), true)
    idx = 1 if idx == -1
    idx = (idx + 1) % scales.length
    $rootScope.csScaling = scales[idx]
    window.updateUnits(true)

  $scope.displayUnits = ->
    return "oz" if $rootScope.csUnits == "ounces"
    "g"

  $scope.cycleUnits = ->
    $rootScope.csUnits = if $rootScope.csUnits == "ounces" then "grams" else "ounces"
    window.updateUnits(true)

]