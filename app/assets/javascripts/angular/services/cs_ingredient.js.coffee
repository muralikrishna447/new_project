angular.module('ChefStepsApp').factory 'Ingredient', ['$resource', ($resource) ->
  return $resource( "/ingredients/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
      merge: {url: "/ingredients/:id/merge", method: "POST"}
    }
  )]

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