class ChefSteps.Views.ProfileHeader extends ChefSteps.Views.TemplatedView

  el: '.profile-info'
  templateName: 'profile_header'

  initialize: =>
    @model.bind('change', @render)

  render: =>
    @$el.html(@renderTemplate())
    @

