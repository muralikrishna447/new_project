angular.module('ChefStepsApp').service 'Authentication', [ ->
  return
    current_user: ->
      user
    set_current_user: (user) ->
      user = user
  ]

# angular.module('ChefStepsApp').factory 'Ingredient', [
#   '$resource'
#   ($resource) ->
#     return $resource("/ingredients/:id",
#       { detailed: true},
#       {
#         update:
#           method: "PUT"
#         merge:
#           url: "/ingredients/:id/merge"
#           method: "POST"
#       }
#     )
#   ]