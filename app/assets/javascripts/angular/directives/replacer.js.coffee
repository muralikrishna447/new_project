# This is to workaround ng-src on a youtube iframe URL causing an extra history entry to get made.
# Variation on this answer: http://forums.devshed.com/html-programming-1/block-iframe-from-browser-history-problem-91077.html
# I just remove the element from the dom, change the src, then put it back.
#
angular.module('ChefStepsApp').directive 'cssrcreplacer', ["$window", ($window) ->
    priority: 99 # it needs to run after the attributes are interpolated
    link: (scope, element, attr) ->
      attr.$observe "cssrcreplacer", (value) ->
        return unless value
        parent = $(element).parent()
        parent_index = $(element).index()
        $(element).detach()
        attr.$set "src", value
        if parent_index == 0
          parent.prepend(element)
        else
          parent.children().eq(parent_index - 1).after(element)
]