angular.module('ChefStepsApp').controller 'EquipmentIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", "csAlertService", "Equipment", "csUrlService", ($scope, $resource, $http, $filter, $timeout, csAlertService, Equipment, csUrlService) ->
  $scope.searchString = ""
  $scope.dataLoading = 0
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.mergeKeeper = null
  $scope.confirmAction = null
  $scope.editMode = true
  $scope.preventAutoFocus = true
  $scope.addUndo = ->
    true

  $scope.modalOptions =
    backdropFade: true
    dialogFade: true

  $scope.$watch 'cellValue', (v) ->
    console.log v

  # These are the Angular-UI options
  # http://angular-ui.github.io/ng-grid/
  $scope.gridOptions =
    data: 'equipment'
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
        displayName: "Equipment"
        width: "****"
        enableCellEdit: true
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}</div>'
        editableCellTemplate: "<input class='equipment-edit-inpput' ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"equipmentChanged(row.entity)\"}\'/>"
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
        cellTemplate: '<div class="ngCellText colt{{$index}}"><span ng-bind-html-unsafe=\"urlAsNiceText(row.getProperty(col.field))\"/></div>'
        editableCellTemplate: "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"equipmentChanged(row.entity)\"}\'/>"
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

  $scope.equipmentChanged =  (equipment) ->
    csUrlService.fixAmazonLink(equipment)
    $scope.dataLoading += 1
    equipment.$update  # Want to try to move this into the equipment factory
      id: equipment.id
      ->
        console.log("Equipment SAVE WIN")
        $scope.dataLoading -= 1
      (err) ->
        console.log("Equipment SAVE FAIL")
        _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
        $scope.dataLoading -= 1
        $scope.resetEquipment()

  #Call the service for this to condense the code, but add it to the controller so it can be used in the view
  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

  $scope.canMerge = ->
    return false if $scope.gridOptions.selectedItems.length < 2
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo), true)

  $scope.canDelete = ->
    return false if $scope.gridOptions.selectedItems.length == 0
    _.reduce($scope.gridOptions.selectedItems, ((memo, val) -> memo && (val.use_count == 0) ), true)

  $scope.deleteSelected = ->
    _.each $scope.gridOptions.selectedItems, (equipment) ->
      $scope.dataLoading += 1
      equipment.$delete # Want to try to move this into the equipment factory
        id: equipment.id
        ->
          console.log("Equipment DELETE WIN")
          $scope.dataLoading -= 1
          index = $scope.equipment.indexOf(equipment)
          $scope.gridOptions.selectItem(index, false)
          $scope.equipment.splice(index, 1)
          $scope.$apply() if ! $scope.$$phase
        (err) ->
          console.log("Equipment DELETE FAIL")
          _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
          $scope.dataLoading -= 1

  $scope.mergeSelected = (keeper) ->
    $scope.mergeModalOpen = false
    $scope.dataLoading += 1
    keeper.$merge  # Want to try to move this into the equipment factory
      id: keeper.id
      merge: _.map($scope.gridOptions.selectedItems, (si) -> si.id).join(',')
      ->
        console.log("Equipment MERGE WIN")
        $scope.dataLoading -= 1
        # $scope.refreshEquipment()
      (err) ->
        console.log("Equipment MERGE FAIL")
        _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
        $scope.dataLoading -= 1

  $scope.uses = (equipment) ->
    result = equipment.activities
    _.each equipment.steps, (step) ->
      entry = _.find(result, (activity) -> activity.id == step.activity.id)
      result.push(step.activity) if ! entry
    result

  $scope.openUses = (equipment) ->
    $scope.usesForModalEquipment = equipment
    $scope.usesForModal = $scope.uses(equipment)
    $scope.usesModalOpen = true

  $scope.computeUseCount = (equipment) ->
    equipment.use_count = $scope.uses(equipment).length

  $scope.loadEquipment =  (num) ->
    $scope.dataLoading += 1
    searchWas = $scope.searchString
    offset = $scope.equipment.length
    num ||= $scope.perPage

    Equipment.query  # Want to try to move this into the equipment factory
      search_title: ($scope.searchString || "")
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: num
      (response) ->
        $scope.dataLoading -= 1
        # Avoid race condition with results coming in out of order
        if searchWas == $scope.searchString
          _.each(response, (item) -> $scope.computeUseCount(item))
          $scope.equipment[offset..offset + num] = response
      (err) ->
        alert(err)

  $scope.resetEquipment = ->
    $scope.equipment = []
    $scope.loadEquipment()

  $scope.refreshEquipment = ->
    num = $scope.equipment.length
    $scope.equipment.length = 0
    $scope.gridOptions.selectedItems.length = 0
    $scope.loadEquipment(num)

  $scope.$watch 'searchString',  (new_val) ->
    # Don't search til the string has been stable for a bit, to avoid bogging down
    $timeout ->
      if new_val == $scope.searchString
        $scope.resetEquipment()
    , 250

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    unless _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetEquipment()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadEquipment()

  $scope.closeAlert = (index) ->
    csAlertService.closeAlert(index, $scope)

  $scope.setMergeKeeper = (equipment) ->
    $scope.mergeKeeper = equipment

  $scope.splitNote = (equipment) ->
    idx = equipment.title.indexOf(",")
    return null if idx < 0
    $.trim(equipment.title.substring(idx + 1))
]

