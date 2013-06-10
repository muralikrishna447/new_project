angular.module('ChefStepsApp').controller 'IngredientsController', ["$scope", "$timeout", "$http", "limitToFilter", ($scope, $timeout, $http, limitToFilter) ->

  $scope.ingredient_display_type = (ai) ->
    result = "basic"
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
    item = {unit: "g"}
    $scope.activity.ingredients.push(item)
  #$scope.addUndo()

  $scope.removeIngredient = (index) ->
    $scope.activity.ingredients.splice(index, 1)
    $scope.addUndo()

  $scope.all_ingredients = (term) ->
    console.log("-" + term + "-")
    s = ChefSteps.splitIngredient(term)
    console.log("-" + term + "-")
    $http.get("/ingredients.json?q=" + s["ingredient"]).then (response) ->
      r = limitToFilter(response.data, 15)
      # always include current search text as an option
      r.unshift({title: s["ingredient"]}) if s["ingredient"]? && !_.find(r, (i) -> i.title == s["ingredient"])
      r


  $scope.matchableIngredients = (i1, i2) ->
    # Use title, not id b/c new ingredients not saved yet don't have an id
    (i1.ingredient.title == i2.ingredient.title) &&
    ((i1.note || "") == (i2.note || "")) &&
    (i1.unit == i2.unit)

  $scope.fillMasterIngredientsFromSteps = ->
    old_ingredients = $scope.activity.ingredients
    $scope.activity.ingredients = []

    for step in $scope.activity.steps
      for si in step.ingredients
        ing = _.find($scope.activity.ingredients, (ai) -> $scope.matchableIngredients(ai, si))
        if ing?
          if ing.unit != "a/n"
            ing.display_quantity = parseFloat(ing.display_quantity) + parseFloat(si.display_quantity)
        else
          $scope.activity.ingredients.push(deepCopy(si))

    # We don't want the behavior of freshly added ingredients getting focus. Not the prettiest solution, but
    # whatayagonnado.
    $scope.preventAutoFocus = true
    $timeout ( ->
      $scope.preventAutoFocus = false
    ), 100

]