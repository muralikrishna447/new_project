angular.module('ChefStepsApp').directive 'affixableoffsetbottom', ["$window", "$document", ($window, $document) ->
  restrict: 'A'
  controller: ['$scope', '$window', ($scope, $window) ->
    $scope.setOffsetBottom = (elem,offset) ->
      window_scrollTop = $($window).scrollTop()
      doc_height = $($document).height()
      elem_height = elem.height()
      offset_point = doc_height - elem_height - offset
      new_elem_position = window_scrollTop - offset_point
      console.log new_elem_position
      if new_elem_position > 0
        # elem.addClass('affixable_offset_bottom-fixed')
        console.log "TRUE"
        elem.css('margin-top', - + new_elem_position)
      else
        # elem.removeClass('affixable_offset_bottom-fixed')
        console.log "FALSE"
        elem.css('margin-top', 0)
  ]

  link: (scope, elem, attrs) ->
    offset = attrs.affixableoffsetbottom
    $($window).scroll ->
      console.log $($window).width()
      if $($window).width() > 767
        scope.setOffsetBottom(elem,offset)
]