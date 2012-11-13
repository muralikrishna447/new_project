class ChefSteps.Views.ShowProfile extends Backbone.View

  initialize: =>
    @model.bind('change', @updateValues)

  updateValues: =>
    _.each @model.attributes, (value, name) =>
      $("[data-attribute=profile-#{name}]").text(value)

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

