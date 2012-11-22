class ChefSteps.Views.Profile extends Backbone.View

  initialize: (options)=>
    @showProfileView = ChefSteps.new(ChefSteps.Views.ShowProfile, model: @model, el: '.user-profile-bio')
    @editProfileView = ChefSteps.new(ChefSteps.Views.EditProfile, model: @model, el: '.edit-user-profile')
    @showProfileView.checkEmptyValues()
    @registrationCompletionPath = options.registrationCompletionPath

    @model.on 'change:profile_complete', @profileCompleteChange, @

    @showEditProfile() unless @model.get('profile_complete')

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

  profileCompleteChange: ->
    window.open(@registrationCompletionPath, "_self")

