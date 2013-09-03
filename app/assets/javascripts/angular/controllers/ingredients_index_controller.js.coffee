angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", ($scope, $resource, $http, $filter, $timeout) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.toCommit = []
  $scope.includeRecipes = false

  $scope.$watch 'cellValue', (v) ->
    console.log v

  cellEditableTemplate = "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ng-change=\"ingredientChanged(row.entity)\"/>"
  cellTitleEditableTemplate = "<input ng-readonly=\"row.getProperty('sub_activity_id')\"  ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ng-change=\"ingredientChanged(row.entity)\"/>"

  Ingredient = $resource( "/ingredients/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
      merge: {url: "/ingredients/:id/merge", method: "POST"}
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
        width: "***"
        enableCellEdit: true
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}{{row.getProperty("sub_activity_id") && " [RECIPE]"}}</div>'
        editableCellTemplate: cellTitleEditableTemplate
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
        cellTemplate: '<div class="ngCellText colt{{$index}}"><a ng-click=\"openUses(row.entity)\"><span ng-bind-html-unsafe=\"row.getProperty(col.field)\"/></a></div>'
        sortable: false
      }
    ]

  $scope.modalOptions = {backdropFade: true, dialogFade:true}

  $scope.ingredientChanged =  (ingredient) ->
    $scope.toCommit = _.union($scope.toCommit, ingredient)

  # From http://stackoverflow.com/questions/5999118/add-or-update-query-string-parameter
  updateQueryStringParameter = (uri, key, value) ->
    re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i")
    separator = (if uri.indexOf("?") isnt -1 then "&" else "?")
    if uri.match(re)
      uri.replace re, "$1" + key + "=" + value + "$2"
    else
      uri + separator + key + "=" + value

  fixAmazonLink = (i) ->
    tag_value = "delvkitc-20"
    tag = "tag=" + tag_value
    url = i.product_url
    if url
      if url.match(/^[\w\d]{10}$/)
        i.product_url = "http://www.amazon.com/gp/product/" + url + "/?" + tag
      else if url.indexOf('amazon.com') != -1
        if url.indexOf(tag) == -1
          i.product_url = updateQueryStringParameter(url, "tag", tag_value)

  $scope.$on 'ngGridEventEndCellEdit', ->
    _.each($scope.toCommit, (ingredient) ->
      fixAmazonLink(ingredient)
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

  $scope.canMerge = ->
    return false if $scope.gridOptions.selectedItems.length < 2
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo && (! val.sub_activity_id)), true)

  $scope.canDelete = ->
    return false if $scope.gridOptions.selectedItems.length == 0
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo && (val.use_count == 0) && (! val.sub_activity_id)), true)

  $scope.deleteSelected = ->
    _.each $scope.gridOptions.selectedItems, (ingredient) ->
      $scope.dataLoading = $scope.dataLoading + 1
      ingredient.$delete({id: ingredient.id},
      ( ->
        console.log("INGREDIENT DELETE WIN")
        $scope.dataLoading = $scope.dataLoading - 1
        index = $scope.ingredients.indexOf(ingredient)
        $scope.gridOptions.selectItem(index, false)
        $scope.ingredients.splice(index, 1)
        $scope.$apply() if ! $scope.$$phase
      ),
      ((err) ->
        console.log("INGREDIENT DELETE FAIL")
        _.each(err.data.errors, (e) -> $scope.addAlert({message: e}))
        $scope.dataLoading = $scope.dataLoading - 1
      ))

  $scope.mergeSelected = (keeper) ->
    $scope.dataLoading = $scope.dataLoading + 1
    keeper.$merge({id: keeper.id, merge: _.map($scope.gridOptions.selectedItems, (si) -> si.id).join(',')},
    ( ->
      console.log("INGREDIENT MERGE WIN")
      $scope.dataLoading = $scope.dataLoading - 1
      $scope.refreshIngredients()
      $timeout ( ->
        $scope.gridOptions.selectedItems = [keeper]
      ), 1000
    ),
    ((err) ->
      console.log("INGREDIENT MERGE FAIL")
      _.each(err.data.errors, (e) -> $scope.addAlert({message: e}))
      $scope.dataLoading = $scope.dataLoading - 1
    ))
    $scope.mergeModalOpen = false



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

  $scope.computeUseCount = (ingredient) ->
    ingredient.use_count = $scope.uses(ingredient).length

  $scope.loadIngredients =  (num) ->
    $scope.dataLoading = $scope.dataLoading + 1
    searchWas = $scope.searchString
    offset = $scope.ingredients.length
    num = num || $scope.perPage

    Ingredient.query(
      search_title: ($scope.searchString || "")
      include_sub_activities: $scope.includeRecipes
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: num,

    (response) ->
      $scope.dataLoading = $scope.dataLoading - 1
      # Avoid race condition with results coming in out of order
      if searchWas == $scope.searchString
        _.each(response, (item) -> $scope.computeUseCount(item))
        $scope.ingredients[offset..offset + num] = response

    , (err) ->
      alert(err)
    )

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
