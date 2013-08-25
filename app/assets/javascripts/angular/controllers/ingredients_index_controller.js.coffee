angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", ($scope, $resource, $http, $filter) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""

  $scope.$watch 'cellValue', (v) ->
    console.log v

  cellEditableTemplate = "<input style=\"width: 90%\" ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ui-event=\'{blur: \"updateEntity(col, row, cellValue)\"}\' ng-model='cellValue'/>";

  Ingredient = $resource( "/ingredients/:id",
    {},
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
      ""

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
    showColumnMenu: true
    enableCellEditOnFocus: true
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
        displayName: "Affiliate Link"
        width: "**"
        enableCellEdit: true
        sortFn: $scope.sortByNiceURL,
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a href="{{row.getProperty(col.field)}}" target="_blank" ng-show="row.getProperty(col.field)"><i class="icon-external-link"></i></a>{{urlAsNiceText(row.getProperty(col.field))}}</div>'
        editableCellTemplate: cellEditableTemplate
      }
    ]

  $scope.updateEntity =  (column, row, cellValue) ->
    console.log(row.entity)
    console.log(column.field)
    row.entity[column.field] = cellValue

  $scope.updateFilter = ->
    $scope.displayIngredients = $filter("orderBy")($scope.ingredients, "title")
    if ! $scope.includeRecipes
      $scope.displayIngredients = _.reject($scope.displayIngredients, (x) -> x.sub_activity_id?)

  $scope.findIngredients = (term) ->
    $scope.dataLoading = $scope.dataLoading + 1
    Ingredient.query({q: (term || "")},
    (response) ->
      $scope.dataLoading = $scope.dataLoading - 1
      # Avoid race condition with results coming in out of order
      if term == $scope.searchString
        $scope.ingredients = _.reject(response, (x) -> x.title == "")
        $scope.updateFilter()
    , (err) ->
      alert(err)
    )

  $scope.$watch 'searchString', (newValue) ->
    $scope.findIngredients(newValue)

  $scope.$watch 'includeRecipes', ->
    $scope.updateFilter()

]
