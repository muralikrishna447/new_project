angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", ($scope, $resource) ->
  Recipe = $resource('/recipe-gallery/:id')
  $scope.recipes = Recipe.query()

  $scope.recipeImageURL = (recipe, width) ->
    url = ""
    if recipe.featured_image_id
      url = JSON.parse(recipe.featured_image_id).url
      url + "/convert?fit=max&w=#{width}&cache=true"
    else
      url = JSON.parse(recipe.image_id).url
      url + "/convert?fit=max&w=#{width}&cache=true"
]