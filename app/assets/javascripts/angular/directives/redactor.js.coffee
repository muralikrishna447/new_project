angular.module("ui.directives").directive "uiRedactor", ["ui.config", (uiConfig) ->

  require: "ngModel"
  # Not creating own scope b/c that messes with model control; i'm sure there is a fix
  # but note that the currrent way using scope.redactor implies relying on only one ui-redactor
  # per parent scope.
  link: (scope, elm, attrs, ngModelCtrl) ->
    scope.redactor = null

    getVal = -> if scope.redactor then scope.redactor.redactor('get') else null

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
      linkSize: 1000
      linebreaks: true
      placeholder: attrs.placeholder || "Click to start writing"
      # Had to disable shortcuts b/c contrary to doc, [ was increasing indent! 
      shortcuts: false
      # See also csEmitFocus
      focusCallback: -> scope.$emit('childFocused', true)
      blurCallback: -> scope.$emit('childFocused', false)

    scope.$watch getVal, (newVal) ->
      ngModelCtrl.$setViewValue newVal unless ngModelCtrl.$pristine
      
    #watch external model change
    ngModelCtrl.$render = ->
      scope.redactor.redactor('set', ngModelCtrl.$viewValue or '') if scope.redactor?

    expression = if attrs.uiRedactor then scope.$eval(attrs.uiRedactor) else {}

    angular.extend options, expression

    setTimeout ->
      scope.redactor = elm.redactor options
      elm.parent().find('.redactor_toolbar').hide()
]  
