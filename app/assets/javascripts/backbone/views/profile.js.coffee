class ChefSteps.Views.Profile extends Backbone.View

  updateValues: =>
    _.each @model.attributes, (value, name) =>
      $("[data-attribute=profile-#{name}]").text(value)

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

