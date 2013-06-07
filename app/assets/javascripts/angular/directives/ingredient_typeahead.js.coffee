angular.module("ChefStepsApp").directive "ingredientTypeahead", ["$parse", ($parse) ->
  restrict: "A"
  require: "?ngModel"

  link: postLink = (scope, element, attrs, controller) ->
    getter = $parse(attrs.bsTypeahead)
    setter = getter.assign
    value = getter(scope)

    scope.$watch attrs.bsTypeahead, (newValue, oldValue) ->
      value = newValue  if newValue isnt oldValue

    element.attr "data-provide", "typeahead"

    element.typeahead
      source: (query) ->
        (if angular.isFunction(value) then value.apply(null, arguments_) else value)

      minLength: attrs.minLength or 1
      items: attrs.items
      updater: (value) ->
        if controller
          scope.$apply ->
            controller.$setViewValue value

        scope.$emit "typeahead-updated", value
        value

    typeahead = element.data("typeahead")
    typeahead.lookup = (ev) ->
      items = undefined
      @query = @$element.val() or ""
      return (if @shown then @hide() else this)  if @query.length < @options.minLength
      items = (if $.isFunction(@source) then @source(@query, $.proxy(@process, this)) else @source)
      (if items then @process(items) else this)

    if attrs.minLength is "0"
      setTimeout ->
        element.on "focus", ->
          element.val().length is 0 and setTimeout(element.typeahead.bind(element, "lookup"), 200)


]