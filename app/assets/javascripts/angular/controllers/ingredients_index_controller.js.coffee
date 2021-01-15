angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", "csAlertService", "Ingredient", "csUrlService", "csAdminTable", "csDensityService", "csGalleryService", ($scope, $resource, $http, $filter, $timeout, csAlertService, Ingredient, csUrlService, csAdminTable, csDensityService, csGalleryService) ->

  $scope.csAdminTable = csAdminTable # Load our csAdminTable service into the scope.
  $scope.alertService = csAlertService
  $scope.densityService = csDensityService

  $scope.csAdminTable.resetLoading($scope) # Make sure our loading bar is off

  $scope.searchString = ""
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.includeRecipes = false
  $scope.exactMatch = false
  $scope.mergeKeeper = null
  $scope.confirmAction = null
  $scope.densityIngredient = null
  $scope.editMode = true
  $scope.preventAutoFocus = true

  $scope.modalOptions =
    backdropFade: true
    dialogFade: true

  $scope.$watch 'cellValue', (v) ->
    console.log v

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
        field: "ingredient_show_url"
        display_name: ""
        width: 24
        maxwidth: 24
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a href="/ingredients/{{row.getProperty(\'slug\')}}" target="_blank"  ng-show=\"! row.getProperty(\'sub_activity_id\')\")" ><i class="icon-external-link"></i></a></div>'
      }      
      {
        field: "title"
        displayName: "Ingredient"
        width: "****"
        enableCellEdit: true
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}{{row.getProperty("sub_activity_id") && " [RECIPE]"}}</div>'
        editableCellTemplate: "<input class='ingredient-edit-inpput' ng-readonly=\"row.getProperty('sub_activity_id')\"  ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"ingredientChanged(row.entity)\"}\'/>"
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
        sortFn: csUrlService.sortByNiceURL
        cellTemplate: '<div class="ngCellText colt{{$index}}"><span ng-bind-html=\"urlAsNiceText(row.getProperty(col.field))\"/></div>'
        # cellTemplate: "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"ingredientChanged(row.entity)\"}\'/>"
        editableCellTemplate: "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"ingredientChanged(row.entity)\"}\'/>"
      }
      {
        field: "density"
        displayName: "Density g/L"
        width: "*"
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a ng-click=\"densityService.editDensity(row.entity)\"><span ng-bind-html=\"densityService.displayDensity(row.getProperty(col.field))\"/></a></div>'
        enableCellEdit: false
        sortable: true
      }
      {
        field: "use_count"
        displayName: "Uses"
        width: "*"
        enableCellEdit: false
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a ng-click=\"openUses(row.entity)\"><span ng-bind-html=\"row.getProperty(col.field).toString()\"/></a></div>'
        sortable: false
      }
    ]

  $scope.ingredientChanged =  (ingredient) ->
    csUrlService.fixAffiliateLink(ingredient)
    $scope.dataLoading += 1
    ingredient.$update  # Want to try to move this into the ingredient factory
      id: ingredient.id
      ->
        $scope.csAdminTable.changedSuccess("Ingredient", $scope)
      (err) ->
        $scope.csAdminTable.changedFailure("Ingredient", err, $scope)

  #Call the service for this to condense the code, but add it to the controller so it can be used in the view
  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

  $scope.canMerge = ->
    return false if $scope.gridOptions.selectedItems.length < 2
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo && (! val.sub_activity_id)), true)

  $scope.canDelete = ->
    return false if $scope.gridOptions.selectedItems.length == 0
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo && (val.use_count == 0) && (! val.sub_activity_id)), true)

  $scope.deleteSelected = ->
    $scope.csAdminTable.deleteSelected("Ingredients", $scope)

  $scope.mergeSelected = (keeper) ->
    $scope.mergeModalOpen = false
    $scope.dataLoading += 1
    keeper.$merge  # Want to try to move this into the ingredient factory
      id: keeper.id
      merge: _.map($scope.gridOptions.selectedItems, (si) -> si.id).join(',')
      ->
        $scope.csAdminTable.mergeSuccess("Ingredient", $scope)
      (err) ->
        $scope.csAdminTable.mergeFailure("Ingredient", err, $scope)

  $scope.uses = (ingredient) ->
    result = ingredient.activities
    _.each ingredient.steps, (step) ->
      if step.activity
        entry = _.find(result, (activity) -> activity.id == step.activity.id)
        result.push(step.activity) if ! entry
    result

  $scope.openUses = (ingredient) ->
    $scope.usesForModalIngredient = ingredient
    $scope.usesForModal = $scope.uses(ingredient)
    $scope.usesModalOpen = true

  $scope.computeUseCount = (ingredient) ->
    ingredient.use_count = $scope.uses(ingredient).length

  $scope.loadIngredients =  (num) ->
    $scope.dataLoading += 1
    searchWas = $scope.searchString
    offset = $scope.ingredients.length
    num ||= $scope.perPage

    Ingredient.query  # Want to try to move this into the ingredient factory
      search_title: ($scope.searchString || "")
      include_sub_activities: $scope.includeRecipes
      exact_match: $scope.exactMatch
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
        $scope.csAdminTable.loadFailure("Ingredient", err, $scope)

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
    $timeout ->
      if new_val == $scope.searchString
        $scope.resetIngredients()
    , 250

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    unless _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetIngredients()

  $scope.$watch 'includeRecipes', ->
    $scope.resetIngredients()

  $scope.$watch 'exactMatch', ->
    $scope.resetIngredients()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadIngredients()

  $scope.setMergeKeeper = (ingredient) ->
    $scope.mergeKeeper = ingredient

  $scope.splitNote = (ingredient) ->
    idx = ingredient.title.indexOf(",")
    return null if idx < 0
    $.trim(ingredient.title.substring(idx + 1))

  $scope.finishDensityChange = (ingredient) ->
    $scope.ingredientChanged(ingredient)
    $scope.densityService.editDensity(null)
]

