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
      air: false
      buttons: ['bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'link', 'html']
      pastePlainText: true
      linkSize: 1000
      linebreaks: true
      placeholder: attrs.placeholder || "Click to start writing"
      focusCallback: -> elm.parent().find('.redactor_toolbar').show()
      blurCallback: -> elm.parent().find('.redactor_toolbar').hide()

    scope.$watch getVal, (newVal) ->
      ngModelCtrl.$setViewValue newVal unless ngModelCtrl.$pristine

    #watch external model change
    ngModelCtrl.$render = ->
      redactor.redactor('set', ngModelCtrl.$viewValue or '') if redactor?

    expression = if attrs.uiRedactor then scope.$eval(attrs.uiRedactor) else {}

    angular.extend options, expression

    setTimeout ->
      redactor = elm.redactor options
      elm.parent().find('.redactor_toolbar').hide()
]  