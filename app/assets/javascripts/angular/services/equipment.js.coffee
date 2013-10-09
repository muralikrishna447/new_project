angular.module('ChefStepsApp').factory 'Equipment', ['$resource', ($resource) ->
  return $resource( "/equipment/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
      merge: {url: "/equipment/:id/merge", method: "POST"}
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