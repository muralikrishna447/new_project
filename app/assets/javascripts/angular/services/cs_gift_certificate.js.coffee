angular.module('ChefStepsApp').factory 'GiftCertificate', ['$resource', ($resource) ->
  return $resource( "/gift_certificates/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
      merge: {url: "/gift_certificates/:id/merge", method: "POST"}
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