class ChefSteps.Views.Profile extends Backbone.View

  initialize: ->
    @showProfileView = ChefSteps.new(ChefSteps.Views.ShowProfile, model: @model, el: '.user-profile-bio')
    @editProfileView = ChefSteps.new(ChefSteps.Views.EditProfile, model: @model, el: '.edit-user-profile')

  events:
    'click .edit-profile': 'showEditProfile'
    'click .save-profile': 'saveProfile'

  showEditProfile: ->
    @showProfileView.hide()
    @editProfileView.show()

  showProfile: ->
    @editProfileView.hide()
    @showProfileView.show()

  saveProfile: =>
    @model.save(@editProfileView.getProfileValues())
    @showProfile()

