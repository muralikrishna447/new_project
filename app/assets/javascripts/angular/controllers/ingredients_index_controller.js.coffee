angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", ($scope, $resource, $http, $filter, $timeout) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""
  $scope.perPage = 16
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}

  $scope.$watch 'cellValue', (v) ->
    console.log v

  cellEditableTemplate = "<input style=\"width: 90%\" ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ui-event=\'{blur: \"updateEntity(col, row, cellValue)\"}\' ng-model='cellValue'/>";
  cellEditableTemplate = "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ng-change=\"updateEntity2(row.entity)\"/>"

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

  $scope.updateEntity =  (column, row, cellValue) ->
    console.log(row.entity)
    console.log(column.field)
    row.entity[column.field] = cellValue

  $scope.updateEntity2 =  (entity) ->
    console.log(entity)
    Ingredient.update({id: entity.id}, entity)

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

  $scope.$watch 'gridOptions.sortInfo', ->
    $scope.resetIngredients()

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

]
