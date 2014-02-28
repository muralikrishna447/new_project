angular.module("ui.directives").directive "uiRedactor", ["ui.config", (uiConfig) ->

  require: "ngModel"
  link: (scope, elm, attrs, ngModelCtrl) ->
    redactor = null

    getVal = -> if redactor then redactor.redactor('get') else null

    apply = ->
      ngModelCtrl.$pristine = false
      scope.$apply()

    options =
      execCommandCallback: apply
      keydownCallback: apply
      keyupCallback: apply
      air: true
      airButtons: ['bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'link']
      pastePlainText: true
      linkSize: false
      placeholder: "Click to start writing"

    scope.$watch getVal, (newVal) ->
      ngModelCtrl.$setViewValue newVal unless ngModelCtrl.$pristine


    #watch external model change
    ngModelCtrl.$render = ->
      redactor.redactor('set', ngModelCtrl.$viewValue or '') if redactor?

    expression = if attrs.uiRedactor then scope.$eval(attrs.uiRedactor) else {}

    angular.extend options, expression

    setTimeout ->
      redactor = elm.redactor options
]  