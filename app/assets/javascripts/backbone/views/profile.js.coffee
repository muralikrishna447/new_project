class ChefSteps.Views.Profile extends Backbone.View

  initialize: (options)=>
    @showProfileView = ChefSteps.new(ChefSteps.Views.ShowProfile, model: @model, el: '.user-profile-bio')
    @editProfileView = ChefSteps.new(ChefSteps.Views.EditProfile, model: @model, el: '.edit-user-profile')
    @showProfileView.checkEmptyValues()
    @registrationCompletionPath = options.registrationCompletionPath

  events:
    'click .edit-profile': 'showEditProfile'
    'click .save-profile': 'saveProfile'
    'click .edit-profile-cancel': 'showProfile'

  showEditProfile: ->
    @showProfileView.hide()
    @editProfileView.show()

  showProfile: ->
    @editProfileView.hide()
    @showProfileView.show()

  saveProfile: =>
    @model.save(@editProfileView.getProfileValues())
    @showProfile()
    @showProfileView.checkEmptyValues()
    if @completion_url?
      window.open(@completion_url, "_self")

