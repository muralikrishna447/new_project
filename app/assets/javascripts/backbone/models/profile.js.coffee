class ChefSteps.Models.Profile extends Backbone.Model
  urlRoot: "/profiles"

  formKeys: [ 'location', 'name', 'quote', 'website' ]
  radioKeys: [ 'chef_type' ]

  url: ->
    "/#{@urlRoot}/#{@slugOrId()}"

  slugOrId: ->
    @get('slug') || @get('id')

  chefType: ->
    map =
      'professional_chef': 'Professional Chef'
      'culinary_student': 'Culinary Student'
      'home_cook': 'Home Cook'
      'novice': 'Novice'
      'other': 'Other'
    map[@get('chef_type')] || ''
