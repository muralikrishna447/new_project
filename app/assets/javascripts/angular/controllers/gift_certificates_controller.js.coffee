angular.module('ChefStepsApp').controller 'GiftCertificatesController', ["$scope", "$resource", "$http", "$filter", "$timeout", "csAlertService", "GiftCertificate", "csUrlService", "csAdminTable", "csDensityService", ($scope, $resource, $http, $filter, $timeout, csAlertService, GiftCertificate, csUrlService, csAdminTable, csDensityService) ->
  $scope.csAdminTable = csAdminTable # Load our csAdminTable service into the scope.
  $scope.alertService = csAlertService
  $scope.csAdminTable.resetLoading($scope) # Make sure our loading bar is off

  $scope.searchString = ""
  $scope.cellValue = ""
  $scope.perPage = 24
  $scope.sortInfo = {fields: ["created_at"], directions: ["asc"]}
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
    data: 'gift_certificates'
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
        field: "created_at"
        display_name: "Created At"
        width: "*"
        maxwidth: 24
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(\'created_at\')}}</div>'
      }
      {
        field: "recipient_email"
        displayName: "Recipient"
        width: "**"
        enableCellEdit: false
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(\'recipient_name\')}} ({{row.getProperty(col.field)}})</div>'
      }
      {
        field: "redeemed"
        displayName: "Redeemed?"
        width: 75
        maxWidth: 75
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(col.field)}}</div>'
      }
      {
        field: "purchaser"
        displayName: "Purchaser"
        width: "*"
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(\'user\').name}}</div>'
      }
      {
        field: "assembly"
        displayName: "Class"
        width: "*"
        enableCellEdit: false
        sortable: false
        cellTemplate: '<div class="ngCellText colt{{$index}}">{{row.getProperty(\'assembly\').title}}</div>'
      }

    ]

  $scope.loadGiftCertificates =  (num) ->
    $scope.dataLoading += 1
    searchWas = $scope.searchString
    offset = $scope.gift_certificates.length
    num ||= $scope.perPage

    GiftCertificate.query  # Want to try to move this into the gift ceriticate factory
      search_title: ($scope.searchString || "")
      exact_match: $scope.exactMatch
      sort: $scope.sortInfo.fields[0]
      dir: $scope.sortInfo.directions[0]
      offset: offset
      limit: num
      (response) ->
        $scope.dataLoading -= 1
        # Avoid race condition with results coming in out of order
        if searchWas == $scope.searchString
          $scope.gift_certificates[offset..offset + num] = response
      (err) ->
        $scope.csAdminTable.loadFailure("GiftCertificate", err, $scope)

  $scope.resetGiftCertificates = ->
    $scope.gift_certificates = []
    $scope.loadGiftCertificates()

  $scope.refreshGiftCertificates = ->
    num = $scope.gift_certificates.length
    $scope.gift_certificates.length = 0
    $scope.gridOptions.selectedItems.length = 0
    $scope.loadGiftCertificates(num)

  $scope.$watch 'searchString',  (new_val) ->
    # Don't search til the string has been stable for a bit, to avoid bogging down
    $timeout ->
      if new_val == $scope.searchString
        $scope.resetGiftCertificates()
    , 250

  # Doc says to just watch sortInfo but not so much
  prevSortInfo = {}
  $scope.$on 'ngGridEventSorted', (event, sortInfo) ->
    unless _.isEqual(sortInfo, prevSortInfo)
      prevSortInfo = jQuery.extend(true, {}, sortInfo)
      $scope.resetGiftCertificates()

  $scope.$on 'ngGridEventScroll', ->
    $scope.loadGiftCertificates()

]

