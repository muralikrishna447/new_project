class ChefSteps.Views.EditProfile extends Backbone.View
  getProfileValues: =>
    attributes = {}
    _.each @model.attributes, (value, name) =>
      attributes[name] = @$("[name='#{name}']").val()
    attributes

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

