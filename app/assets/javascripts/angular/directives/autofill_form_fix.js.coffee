#This directive is to make angular aware of the values of autofills on submit of a form.
angular.module('ChefStepsApp').directive 'formAutofillFix', ->
  (scope, elem, attrs) ->
    # Fixes Chrome bug: https://groups.google.com/forum/#!topic/angular/6NlucSskQjY
    elem.prop 'method', 'POST'

    # Fix autofill issues where Angular doesn't know about autofilled inputs
    if attrs.ngSubmit
      setTimeout ->
        elem.unbind('submit').submit (e) ->
          e.preventDefault()
          elem.find('input, textarea, select').trigger('input').trigger('change').trigger 'keydown'
          scope.$apply attrs.ngSubmit
      , 0