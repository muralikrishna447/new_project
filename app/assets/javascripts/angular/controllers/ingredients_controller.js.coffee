angular.module('ChefStepsApp').controller 'IngredientsController', ["$scope", "$rootScope", "$timeout", "$http", "limitToFilter", "csUrlService", ($scope, $rootScope, $timeout, $http, limitToFilter, csUrlService) ->

  $scope.shouldShowMasterIngredientsRemovedModal = false
  $scope.showIngredientsMenu = false
  $scope.includeRecipes = false
  $scope.preventAutoFocus = true

  $scope.viewOptions = {}
  $scope.viewOptions.includeRecipes = false
  $scope.csUrlService = csUrlService

  $scope.getAllUnits = ->
    window.allUnits

  $scope.ingredient_display_type = (ai) ->
    result = "basic"
    if ai?.ingredient?
      result = "subrecipe" if !! ai.ingredient.sub_activity_id
      result = "fake_link" if $scope.editMode
    result

  $scope.unitMultiplier = (unit_name) ->
    result = 1
    result = 1000 if unit_name == "kg"
    result

  $scope.outclickProduct = (ai) ->
    window.open(ai.ingredient.product_url, '_blank')
    mixpanel.track('Buy Clicked', {source: 'ingredientList', 'activitySlug' : $scope.activity.slug, 'productSlug' : ai.ingredient.slug});

  $scope.removeIngredient = (index) ->
    $scope.getIngredientsList().splice(index, 1)

  $scope.all_ingredients = (term, includeRecipes) ->
    s = ChefSteps.splitIngredient(term)
    $http.get("/ingredients.json?limit=15&include_sub_activities=#{$scope.includeRecipes}&search_title=" + s["ingredient"]).then (response) ->
      r = response.data
      for i in r
        i.label = i.title
        i.label += " [RECIPE]" if i.sub_activity_id?

      # always include current search text as an option, first!
      r = _.sortBy(r, (i) -> i.title != s["ingredient"])
      r.unshift({title: s["ingredient"], label: s["ingredient"]}) if s["ingredient"]? && !_.find(r, (i) -> i.title == s["ingredient"])
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
    $scope.temporaryNoAutofocus()
    if $scope.activity.ingredients.length < old_count
      $scope.shouldShowMasterIngredientsRemovedModal = true

  $scope.loadSubrecipe = (id) ->
    window.location.href = '/activities/' + id unless $scope.overrideLoadActivity?(id)


  lastCustomScale = 1
  baseScales = [0.5, 1, 2, 4]

  $scope.$watch 'csGlobals.scaling', (newValue) ->
    if baseScales.indexOf(newValue) < 0
      lastCustomScale = newValue

  $scope.scaleFactors = ->
    r = baseScales
    if lastCustomScale != 1
      r.pop()
      r.push(lastCustomScale)
      r = _.sortBy(r, (x) -> x)
    r

  $scope.toggleIngredientsMenu = ->
    $scope.showIngredientsMenu = ! $scope.showIngredientsMenu
    if $scope.showIngredientsMenu
      mixpanel.track('Ingredients Menu Opened', {'slug' : $scope.activity.slug});

  $scope.setScaling = (newScale) ->
    $scope.csGlobals.scaling = newScale
    window.updateUnits(true)
    mixpanel.track('Scaling Changed', {'slug' : $scope.activity.slug, 'scale' : newScale});

  $scope.isActiveScale = (scale) ->
    return "active" if scale == $scope.csGlobals.scaling
    ""

  $scope.unitChoices = ->
    ["grams", "ounces"]

  $scope.setUnits = (unit) ->
    $scope.csGlobals.units = unit
    window.updateUnits(true)
    mixpanel.track('Units Button Pushed', {'slug' : $scope.activity.slug});

  $scope.isActiveUnit = (unit) ->
    return "active" if $scope.csGlobals.units == unit
    ""

]