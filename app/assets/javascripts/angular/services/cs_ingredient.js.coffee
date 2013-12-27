@app.factory 'Ingredient', ['$resource', ($resource) ->
  return $resource( "/ingredients/:id",
    { detailed: true},
    {
      update: {method: "PUT"},
      merge: {url: "/ingredients/:id/merge", method: "POST"}
      index_for_gallery: {method: "GET", url: "/ingredients/index_for_gallery.json", isArray: true}
    }
  )]

# This can't be the best way to do this, but I can't figure out how to get the objects return from
# $resource above to be Activities, not just Resources, so I can add these methods to the protoype.
@app.service 'IngredientMethods', ["Ingredient", (Ingredient) ->

  this.placeHolderImage = ->
    "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

  this.itemImageFpfile = (ingredient) ->
    if ingredient.image_id
        return JSON.parse(ingredient.image_id)

  this.queryIndex = ->
    Ingredient.index_for_gallery

]