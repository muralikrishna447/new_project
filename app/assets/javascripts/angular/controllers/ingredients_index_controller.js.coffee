angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", ($scope, $resource, $http, $filter, $timeout) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""
  $scope.perPage = 16
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.toCommit = []

  $scope.$watch 'cellValue', (v) ->
    console.log v

  cellEditableTemplate = "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ng-change=\"ingredientChanged(row.entity)\"/>"

  Ingredient = $resource( "/ingredients/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
    }
  )

  $scope.urlAsNiceText = (url) ->
    if url
      result = "Link"
      return "amazon.com" if url.indexOf("amzn") != -1
      matches = url.match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i);
      if matches && matches[1]
        result = matches[1]
        result = result.replace('www.', '')
      result
    else
      "&nbsp;"

  $scope.sortByNiceURL = (a, b) ->
    na = $scope.urlAsNiceText(a)
    nb = $scope.urlAsNiceText(b)
    return 0 if na == nb
    return 1 if na > nb
    -1

  $scope.gridOptions =
    data: 'displayIngredients'
    showSelectionCheckbox: true
    selectWithCheckboxOnly: true
    enableCellEditOnFocus: true
    enableColumnReordering: true
    groupable: false
    useExternalSorting: true
    sortInfo: $scope.sortInfo
    columnDefs: [
      {
        field: "title"
        displayName: "Ingredient"
        width: "***"
        enableCellEdit: true
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}{{row.getProperty("sub_activity_id") && " [RECIPE]"}}</div>'
        editableCellTemplate: cellEditableTemplate
      },
      {
        field: "product_url"
        displayName: ""
        width: 24
        maxWidth: 24
        enableCellEdit: false
        sortable: false,
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a href="{{row.getProperty(col.field)}}" target="_blank"  ng-show="row.getProperty(col.field)" ><i class="icon-external-link"></i></a></div>'
      }
      {
        field: "product_url"
        displayName: "Affiliate Link"
        width: "**"
        enableCellEdit: true
        sortFn: $scope.sortByNiceURL,
        cellTemplate: '<div class="ngCellText colt{{$index}}"><span ng-bind-html-unsafe=\"urlAsNiceText(row.getProperty(col.field))\"/></div>'
        editableCellTemplate: cellEditableTemplate
      }
      {
        field: "use_count"
        displayName: "Uses"
        width: "*"
        enableCellEdit: false
        sortable: false
      }
    ]

   $scope.ingredientChanged =  (ingredient) ->
    $scope.toCommit = _.union($scope.toCommit, ingredient)

  $scope.$on 'ngGridEventEndCellEdit', ->
    _.each($scope.toCommit, (ingredient) ->
      console.log(ingredient)
      $scope.dataLoading = $scope.dataLoading + 1
      ingredient.$update({id: ingredient.id},
      ( ->
        console.log("INGREDIENT SAVE WIN")
        $scope.dataLoading = $scope.dataLoading - 1
      ),
      ((err) ->
        console.log("INGREDIENT SAVE FAIL")
        _.each(err.data.errors, (e) -> $scope.addAlert({message: e}))
        $scope.dataLoading = $scope.dataLoading - 1
        $scope.resetIngredients()
      ))
    )
    $scope.toCommit = []

  $scope.updateFilter = ->
    $scope.displayIngredients = $scope.ingredients

  $scope.computeUseCount = (item) ->
    activity_ids = _.map(item.activities, (a) -> a.id)
    step_ids = _.map(item.steps, (s) -> s.activity.id)
    # Normally an ingredient shouldn't be in a step without being in the corresponding recipe, but
    # it can happen.
    u = _.union(activity_ids, step_ids)
    item.use_count = u.length

  $scope.loadIngredients =  ->
    $scope.dataLoading = $scope.dataLoading + 1
    searchWas = $scope.searchString
    offset = $scope.ingredients.length

    Ingredient.query(
      search_title: ($scope.searchString || "")
      include_sub_activities: $scope.includeRecipes
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: $scope.perPage,

    (response) ->
      $scope.dataLoading = $scope.dataLoading - 1
      # Avoid race condition with results coming in out of order
      if searchWas == $scope.searchString
        _.each(response, (item) -> $scope.computeUseCount(item))
        $scope.ingredients[offset..offset + $scope.perPage] = response
        $scope.updateFilter()

    , (err) ->
      alert(err)
    )

  $scope.resetIngredients = ->
    $scope.ingredients = []
    $scope.displayIngredients = []
    $scope.loadIngredients()

  $scope.$watch 'searchString',  (new_val) ->
    # Don't search til the string has been stable for a bit, to avoid bogging down
    $timeout ( ->
      if new_val == $scope.searchString
        $scope.resetIngredients()
    ), 250

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    if ! _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetIngredients()

  $scope.$watch 'includeRecipes', ->
    $scope.resetIngredients()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadIngredients()

  # DRY up with activity controller. Make a service or something.
  $scope.addAlert = (alert) ->
    $scope.alerts.push(alert)
    $timeout ->
      $("html, body").animate({ scrollTop: -500 }, "slow")

  $scope.closeAlert = (index) ->
    $scope.alerts.splice(index, 1)

]
