
@app.factory 'Ingredient', ['$resource', ($resource) ->
  return $resource( "/ingredients/:id",
    { detailed: true, format: "json"},
    {
      get_as_json: {url: "/ingredients/:id/as_json", method: "GET"}
      update: {method: "PUT"},
      merge: {url: "/ingredients/:id/merge", method: "POST"}
      index_for_gallery: {method: "GET", url: "/ingredients/index_for_gallery.json", isArray: true}
      create: {url: "/ingredients", method: "POST"}
    }
  )

]