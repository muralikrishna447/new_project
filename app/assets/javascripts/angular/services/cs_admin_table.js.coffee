angular.module('ChefStepsApp').service 'csAdminTable', ["$timeout", "csAlertService", ($timeout, csAlertService)  ->
  # Safety/Santity Methods
  this.isAValidType = (type) ->
    type in ["Equipment", "Ingredient", "Ingredients"] # MUST add new types here or else they will not be recognized for EVAL statements

  this.gridData = ->
    "Equipment": "equipment"
    "Ingredient": "ingredients"

  # Loading methods
  this.startLoading = ($scope) ->
    $scope.dataLoading += 1

  this.finishLoading = ($scope) ->
    $scope.dataLoading -= 1

  this.resetLoading = ($scope) ->
    $scope.dataLoading = 0

  # Response Methods
  this.changedSuccess = (type, $scope) ->
    console.log("#{type} SAVE WIN")
    this.finishLoading($scope)

  this.changedFailure = (type, err, $scope) ->
    console.log("#{type} SAVE FAIL")
    _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
    this.finishLoading($scope)
    # $scope.resetEquipment()
    eval("$scope.reset#{type}") if this.isAValidType(type)

  this.deleteSelected = (type, $scope) ->
    _.each $scope.gridOptions.selectedItems, (object) ->
      $scope.csAdminTable.startLoading($scope)
      object.$delete
        id: object.id
        ->
          $scope.csAdminTable.deleteSuccess(type, $scope, object)
        (err) ->
          $scope.csAdminTable.deleteFailure(type, err, $scope)

  this.deleteSuccess = (type, $scope, object) ->
    console.log("#{type} DELETE WIN")
    this.finishLoading($scope)
    # index = $scope.equipment.indexOf(equipment)
    eval("index = $scope.#{type.toLowerCase()}.indexOf(object)") if this.isAValidType(type)
    $scope.gridOptions.selectItem(index, false)
    eval("$scope.#{type.toLowerCase()}.splice(index, 1)") if this.isAValidType(type)
    $scope.$apply() if ! $scope.$$phase

  this.deleteFailure = (type, err, $scope) ->
    console.log("#{type} DELETE FAIL")
    _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
    this.finishLoading($scope)

  this.mergeSuccess = (type, $scope) ->
    console.log("#{type} MERGE WIN")
    this.finishLoading($scope)
    # $scope.refreshEquipment()

  this.mergeFailure = (type, err, $scope) ->
    console.log("#{type} MERGE FAIL")
    _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
    this.finishLoading($scope)
    $scope.gridOptions.selectedItems.length = 0

  # this.loadSuccess = (type, response, searchWas, offset, num, $scope) ->
  #   this.finishLoading($scope)
  #   # Avoid race condition with results coming in out of order
  #   if searchWas == $scope.searchString
  #     _.each(response, (item) -> $scope.computeUseCount(item))
  #     eval("$scope."+ type.toLowerCase +"[offset..offset + num] = response") if this.isAValidType(type)

  this.loadFailure = (type, err, $scope) ->
    this.finishLoading($scope)
    _.each(err.data.errors, (e) -> csAlertService.addAlert({message: e}, $scope, $timeout)) #alerts.addAlert({message: e}))
    # alert(err)


]