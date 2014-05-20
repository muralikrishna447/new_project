angular.module('ChefStepsApp').controller 'EquipmentIndexController', ["$scope", "$resource", "$http", "$filter", "$timeout", "csAlertService", "Equipment", "csUrlService", "csAdminTable", ($scope, $resource, $http, $filter, $timeout, csAlertService, Equipment, csUrlService, csAdminTable) ->
  $scope.csAdminTable = csAdminTable # Load our csAdminTable service into the scope.
  $scope.alertService = csAlertService

  $scope.csAdminTable.resetLoading($scope) # Make sure our loading bar is off

  $scope.searchString = ""
  $scope.exactMatch = false
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["title"], directions: ["asc"]}
  $scope.alerts = []
  $scope.mergeKeeper = null
  $scope.confirmAction = null
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
        cellTemplate: '<div class="ngCellText colt{{$index}}"><span ng-bind-html=\"urlAsNiceText(row.getProperty(col.field))\"/></div>'
        editableCellTemplate: "<input ng-class=\"'colt' + col.index\" ng-input=\"COL_FIELD\" ng-model=\"COL_FIELD\" ui-event=\'{blur: \"equipmentChanged(row.entity)\"}\'/>"
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

  $scope.equipmentChanged =  (equipment) ->
    csUrlService.fixAmazonLink(equipment)
    $scope.csAdminTable.startLoading($scope)
    equipment.$update  # Want to try to move this into the equipment factory
      id: equipment.id
      ->
        $scope.csAdminTable.changedSuccess("Equipment", $scope)
      (err) ->
        $scope.csAdminTable.changedFailure("Equipment", err, $scope)

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
    $scope.csAdminTable.deleteSelected("Equipment", $scope)

  $scope.mergeSelected = (keeper) ->
    $scope.mergeModalOpen = false
    $scope.csAdminTable.startLoading($scope)
    keeper.$merge  # Want to try to move this into the equipment factory
      id: keeper.id
      merge: _.map($scope.gridOptions.selectedItems, (si) -> si.id).join(',')
      ->
        $scope.csAdminTable.mergeSuccess("Equipment", $scope)
      (err) ->
        $scope.csAdminTable.mergeFailure("Equipment", err, $scope)

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
    $scope.csAdminTable.startLoading($scope)
    searchWas = $scope.searchString
    offset = $scope.equipment.length
    num ||= $scope.perPage

    Equipment.query  # Want to try to move this into the equipment factory
      search_title: ($scope.searchString || "")
      exact_match: $scope.exactMatch
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: num
      (response) ->
        $scope.csAdminTable.finishLoading($scope)
        # Avoid race condition with results coming in out of order
        if searchWas == $scope.searchString
          _.each(response, (item) -> $scope.computeUseCount(item))
          $scope.equipment[offset..offset + num] = response
        # $scope.csAdminTable.loadSuccess("Equipment", response, searchWas, offset, num, $scope)
      (err) ->
        $scope.csAdminTable.loadFailure("Equipment", err, $scope)


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

  $scope.$watch 'exactMatch', ->
    $scope.resetEquipment()

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    unless _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetEquipment()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadEquipment()

  $scope.setMergeKeeper = (equipment) ->
    $scope.mergeKeeper = equipment

  $scope.splitNote = (equipment) ->
    idx = equipment.title.indexOf(",")
    return null if idx < 0
    $.trim(equipment.title.substring(idx + 1))
]

