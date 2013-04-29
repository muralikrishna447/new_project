# Angular.js wysiwyg mode stuff. This can't wait til after page load, it needs to happen in the <head>

deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

window.markdownConverter = Markdown.getSanitizingConverter()

csApp = angular.module('ChefStepsApp', ["ngResource", "ui"])

csApp.controller 'ActivityController', ($scope, $resource) ->
  Activity = $resource("/activities/:id", {id:  $('#activity-body').data("activity-id")}, {update: {method: "PUT"}})
  $scope.activity = Activity.get()
  $scope.undoStack = []
  $scope.undoIndex = -1

  # Overall edit mode
  $scope.startEditMode = ->
    $scope.editMode = true
    $scope.undoStack = [deepCopy $scope.activity]
    $scope.undoIndex = 0

  $scope.endEditMode = ->
    $scope.$broadcast('end_all_edits')
    $scope.editMode = false
    $scope.activity.$update()

  $scope.cancelEditMode = ->
    $scope.$broadcast('end_all_edits')
    $scope.editMode = false
    if $scope.undoAvailable
      $scope.activity = deepCopy $scope.undoStack[0]

  # Undo/redo
  $scope.undo = ->
    if $scope.undoAvailable
      $scope.undoIndex -= 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex ]
      $scope.d("After Undo")

  $scope.redo = ->
    if $scope.redoAvailable
      $scope.undoIndex += 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex]
      $scope.d("After Redo")

  $scope.undoAvailable = ->
    $scope.undoIndex > 0

  $scope.redoAvailable = ->
    $scope.undoIndex < ($scope.undoStack.length - 1)

  $scope.addUndo = ->
    # Get rid of any redos past the current spot and put the new state on the stack (unless no change)
    newUndo = deepCopy($scope.activity)
    if ! _.isEqual(newUndo, $scope.undoStack[$scope.undoIndex])
      $scope.undoStack = $scope.undoStack[0..$scope.undoIndex]
      $scope.undoStack.push newUndo
      $scope.undoIndex = $scope.undoStack.length - 1
      $scope.d("After Push")

  $scope.d = (msg) ->
    console.log "------" + msg
    console.log $scope.undoIndex
    idx = 0
    for x in $scope.undoStack
      console.log idx.toString() + ": " + x.title
      idx += 1

  $scope.bodyClick = ->
    if $scope.editMode
      if $(event.target).is('body') || $(event.target).is('html')
        $scope.$broadcast('end_all_edits')



csApp.directive 'cseditgroup', ->
  scope: true,
  controller: ($scope, $element) ->

    $scope.pairs = []

    $scope.deactivateAll = ->
      any_active = false
      angular.forEach $scope.pairs, (pair) ->
        if pair.active
          pair.active = false
          any_active = true
      if any_active
        $scope.addUndo()
        window.wysiwygActivatedCallback($element)

    $scope.$on 'end_all_edits', ->
      $scope.deactivateAll()

    $scope.activate = (pair) ->
      $scope.deactivateAll()
      pair.active = true

    $scope.addPair = (pair) ->
      pair.active = false
      $scope.pairs.push(pair)


# This guys is responsible for showing a highlight on hover that indicates it can
# be edited, and switching between the show and edit children when activated. It
# delegates to the cseditgroup to manage the radio-like behavior so that only one
# pair is activated at a time, and to the app for the undo/redo.
csApp.directive 'cseditpair', ->
  restrict: 'E',
  require: '^cseditgroup',
  transclude: true,
  replace: true,
  scope: true,

  link: (scope, element, attrs, groupControl) ->
    scope.addPair(scope)

  controller: ($scope, $element) ->
    $scope.offerEdit = ->
      if $scope.editMode && ! $scope.active
        $($element).find('.edit-target').show()

    $scope.unofferEdit = ->
      $($element).find('.edit-target').hide()

    # Edit one group
    $scope.startEdit = ->
      $scope.unofferEdit()
      $scope.activate($scope)
      event.stopPropagation()

  template: '<div class="edit-pair" ng-switch="" on="active" ng-mouseover="offerEdit()"><div class="edit-target hide" ng-mouseout="unofferEdit()" ng-click="startEdit()"></div><div ng-transclude></div></div>'

csApp.directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude></div>'

csApp.directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="false" ng-transclude></div>'

###
csApp.directive 'markdown', ->
  priority: 1000
  restrict: "A"
  link: (scope, element, attrs) ->
    htmlText = converter.makeHtml(element.text())
    element.html htmlText###


#csApp.filter 'markdown', (input, scope) ->
#  input + "YEAAAAH!"

#myApp = angular.module("myApp", [])
csApp.filter "markdown", ->
  (input) ->
    if input && markdownConverter
      #alert(markdownConverter.makeHTML(input))
      result = markdownConverter.makeHtml(input)
      result
    else
      ""

