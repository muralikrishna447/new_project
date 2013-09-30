angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", "alertService", "Ingredient", "urlService", ($scope, $resource, $http, $filter, $timeout, alertService, Ingredient, urlService) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.includeRecipes = false
  $scope.mergeKeeper = null
  $scope.confirmAction = null
  $scope.densityIngredient = null
  $scope.editMode = true
  $scope.preventAutoFocus = true
  $scope.addUndo = ->
    true
  $scope.densityUnits =
    [
      {name: 'Tablespoon', perL: 67.628},
      {name: 'Cup', perL: 4.22675},
      {name: 'Liter',  perL: 1}
    ]

  $scope.displayDensity = (x) ->
    if x then window.roundSensible(x) else "Set..."

  $scope.displayDensityNoSet = (x) ->
    if x && _.isNumber(x) then window.roundSensible(x) else ""

  $scope.$watch 'cellValue', (v) ->
    console.log v

  #Call the service for this to condense the code, but add it to the controller so it can be used in the view
  $scope.urlAsNiceText = (url) ->
    urlService.urlAsNiceText(url)

  # These are the Angular-UI options
  # http://angular-ui.github.io/ng-grid/
  $scope.gridOptions =
    data: 'ingredients'
    showSelectionCheckbox: true
    selectWithCheckboxOnly: true
    enableCellEditOnFocus: true
    enableColumnReordering: true
    groupable: false
    useExternalSorting: true
    sortInfo: $scope.sortInfo
    selectedItems: []
    columnDefs: [
      {
        field: "title"
        displayName: "Ingredient"
        width: "****"
        enableCellEdit: true
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}{{row.getProperty("sub_activity_id") && " [RECIPE]"}}</div>'
        editableCellTemplate: "<input ng-readonly=\"row.getProperty('sub_activity_id')\"  ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"ingredientChanged(row.entity)\"}\'/>"
      }
      {
        field: "product_url"
        displayName: ""
        width: 24
        maxWidth: 24
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a href="{{row.getProperty(col.field)}}" target="_blank"  ng-show="row.getProperty(col.field)" ><i class="icon-external-link"></i></a></div>'
      }
      {
        field: "product_url"
        displayName: "Affiliate Link"
        width: "***"
        enableCellEdit: true
        sortFn: urlService.sortByNiceURL
        cellTemplate: '<div class="ngCellText colt{{$index}}"><span ng-bind-html-unsafe=\"urlAsNiceText(row.getProperty(col.field))\"/></div>'
        editableCellTemplate: "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"ingredientChanged(row.entity)\"}\'/>"
      }
      {
        field: "density"
        displayName: "Density g/L"
        width: "*"
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a ng-click=\"editDensity(row.entity)\"><span ng-bind-html-unsafe=\"displayDensity(row.getProperty(col.field))\"/></a></div>'
        enableCellEdit: false
        sortable: true
      }
      {
        field: "use_count"
        displayName: "Uses"
        width: "*"
        enableCellEdit: false
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a ng-click=\"openUses(row.entity)\"><span ng-bind-html-unsafe=\"row.getProperty(col.field)\"/></a></div>'
        sortable: false
      }
    ]

  $scope.modalOptions =
    backdropFade: true
    dialogFade: true

  $scope.ingredientChanged =  (ingredient) ->
    urlService.fixAmazonLink(ingredient)
    $scope.dataLoading += 1
    ingredient.$update
      id: ingredient.id
      ->
        console.log("INGREDIENT SAVE WIN")
        $scope.dataLoading -= 1
      (err) ->
        console.log("INGREDIENT SAVE FAIL")
        _.each(err.data.errors, (e) -> alertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
        $scope.dataLoading -= 1
        $scope.resetIngredients()

  $scope.canMerge = ->
    return false if $scope.gridOptions.selectedItems.length < 2
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo and not val.sub_activity_id), true)

  $scope.canDelete = ->
    return false if $scope.gridOptions.selectedItems.length == 0
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo and val.use_count == 0 and not val.sub_activity_id), true)

  $scope.deleteSelected = ->
    _.each $scope.gridOptions.selectedItems, (ingredient) ->
      $scope.dataLoading += 1
      ingredient.$delete
        id: ingredient.id
        ->
          console.log("INGREDIENT DELETE WIN")
          $scope.dataLoading -= 1
          index = $scope.ingredients.indexOf(ingredient)
          $scope.gridOptions.selectItem(index, false)
          $scope.ingredients.splice(index, 1)
          $scope.$apply() if ! $scope.$$phase
        (err) ->
          console.log("INGREDIENT DELETE FAIL")
          _.each(err.data.errors, (e) -> alertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
          $scope.dataLoading -= 1

  $scope.mergeSelected = (keeper) ->
    $scope.mergeModalOpen = false
    $scope.dataLoading += 1
    keeper.$merge({id: keeper.id, merge: _.map($scope.gridOptions.selectedItems, (si) -> si.id).join(',')},
    ( ->
      console.log("INGREDIENT MERGE WIN")
      $scope.dataLoading -= 1
      #$scope.refreshIngredients()
    ),
    ((err) ->
      console.log("INGREDIENT MERGE FAIL")
      _.each(err.data.errors, (e) -> alertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
      $scope.dataLoading -= 1
    ))

  $scope.uses = (ingredient) ->
    result = ingredient.activities
    _.each ingredient.steps, (step) ->
      entry = _.find(result, (activity) -> activity.id == step.activity.id)
      result.push(step.activity) if ! entry
    result

  $scope.openUses = (ingredient) ->
    $scope.usesForModalIngredient = ingredient
    $scope.usesForModal = $scope.uses(ingredient)
    $scope.usesModalOpen = true

  $scope.editDensity = (ingredient) ->
    $scope.densityIngredient = ingredient

  $scope.finishDensityChange = (ingredient) ->
    $scope.ingredientChanged(ingredient)
    $scope.densityIngredient = null

  $scope.computeUseCount = (ingredient) ->
    ingredient.use_count = $scope.uses(ingredient).length

  $scope.loadIngredients =  (num) ->
    $scope.dataLoading += 1
    searchWas = $scope.searchString
    offset = $scope.ingredients.length
    num ||= $scope.perPage

    Ingredient.query
      search_title: ($scope.searchString || "")
      include_sub_activities: $scope.includeRecipes
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: num
      (response) ->
        $scope.dataLoading -= 1
        # Avoid race condition with results coming in out of order
        if searchWas == $scope.searchString
          _.each(response, (item) -> $scope.computeUseCount(item))
          $scope.ingredients[offset..offset + num] = response
      (err) ->
        alert(err)

  $scope.resetIngredients = ->
    $scope.ingredients = []
    $scope.loadIngredients()

  $scope.refreshIngredients = ->
    num = $scope.ingredients.length
    $scope.ingredients.length = 0
    $scope.gridOptions.selectedItems.length = 0
    $scope.loadIngredients(num)

  $scope.$watch 'searchString',  (new_val) ->
    # Don't search til the string has been stable for a bit, to avoid bogging down
    $timeout ( ->
      if new_val == $scope.searchString
        $scope.resetIngredients()
    ), 250

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    unless _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetIngredients()

  $scope.$watch 'includeRecipes', ->
    $scope.resetIngredients()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadIngredients()

  # DRY up with activity controller. Make a service or something.
  # $scope.addAlert = (alert) ->
  #   $scope.alerts.push(alert)
  #   $timeout ->
  #     $("html, body").animate({ scrollTop: -500 }, "slow")

  $scope.closeAlert = (index) ->
    alertService.closeAlert(index, $scope)

  $scope.setMergeKeeper = (ingredient) ->
    $scope.mergeKeeper = ingredient

  $scope.splitNote = (ingredient) ->
    idx = ingredient.title.indexOf(",")
    return null if idx < 0
    $.trim(ingredient.title.substring(idx + 1))

  $scope.confirmNo = ->
    $scope.confirmAction = null

  $scope.confirmYes = ->
    act = $scope.confirmAction
    $scope.confirmAction = null
    console.log("ConfirmYes")
    console.dir(act)
    eval("$scope." + act)
]

