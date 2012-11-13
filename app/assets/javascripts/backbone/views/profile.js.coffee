class ChefSteps.Views.Profile extends Backbone.View

  initialize: ->
    @profileBioView = ChefSteps.new(ChefSteps.Views.ProfileBio, model: @model, el: '.user-profile-bio')
    @editProfileView = ChefSteps.new(ChefSteps.Views.EditProfile, model: @model, el: '.edit-user-profile')

  events:
    'click .edit-profile': 'showEditProfile'

  showEditProfile: ->
    @profileBioView.hide()
    @editProfileView.show()

  showProfileBio: ->
    @editProfileView.hide()
    @profileBioView.show()

