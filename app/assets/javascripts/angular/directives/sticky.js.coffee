@app.directive "sticky", ($window) ->
  link: (scope, element, attrs) ->
    $win = angular.element($window)
    if scope._stickyElements is `undefined`
      scope._stickyElements = []
      $win.bind "scroll.sticky", (e) ->
        pos = $win.scrollTop()
        i = 0

        while i < scope._stickyElements.length
          item = scope._stickyElements[i]
          if not item.isStuck and pos > item.start
            item.element.addClass "stuck"
            item.isStuck = true
            item.placeholder = angular.element("<div></div>").css(height: item.element.outerHeight() + "px").insertBefore(item.element)  if item.placeholder
          else if item.isStuck and pos < item.start
            item.element.removeClass "stuck"
            item.isStuck = false
            if item.placeholder
              item.placeholder.remove()
              item.placeholder = true
          i++
        return

      recheckPositions = ->
        i = 0

        while i < scope._stickyElements.length
          item = scope._stickyElements[i]
          unless item.isStuck
            item.start = item.element.offset().top
          else item.start = item.placeholder.offset().top  if item.placeholder
          i++
        return

      $win.bind "load", recheckPositions
      $win.bind "resize", recheckPositions
    item =
      element: element
      isStuck: false
      placeholder: attrs.usePlaceholder isnt `undefined`
      start: element.offset().top

    scope._stickyElements.push item
    return
