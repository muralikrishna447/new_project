class ChefSteps.Views.ProfileHeader extends ChefSteps.Views.TemplatedView

  el: '#authentication'

  events:
    "click .profile-info" : "toggleActive"

  initialize: =>
    if @model
      @templateName = 'profile_header_logged_in'
      @model.bind('change', @render)
    else
      @templateName = 'profile_header_logged_out'


  extendTemplateJSON: (templateJSON) =>
    return templateJSON unless @model
    _.extend(templateJSON,
      profile_url: @model.url()
    )

  render: =>
    @$el.html(@renderTemplate())
    @

  toggleActive: (event) ->
    $(event.currentTarget).toggleClass('active')

