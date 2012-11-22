class ChefSteps.Views.Profile extends Backbone.View

  initialize: (options)=>
    @showProfileView = ChefSteps.new(ChefSteps.Views.ShowProfile, model: @model, el: '.user-profile-bio')
    @editProfileView = ChefSteps.new(ChefSteps.Views.EditProfile, model: @model, el: '.edit-user-profile')
    @showProfileView.checkEmptyValues()
    @registrationCompletionPath = options.registrationCompletionPath
    @newUser = options.newUser

    @model.on('sync', @goToRegistrationCompletePage, @) if @newUser

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

  goToRegistrationCompletePage: ->
    window.open(@registrationCompletionPath, "_self")

