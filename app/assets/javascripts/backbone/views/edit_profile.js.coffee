class ChefSteps.Views.EditProfile extends Backbone.View
  getProfileValues: =>
    attributes = {}
    _.each @model.formKeys, (name) =>
      attributes[name] = @$("[name='#{name}']").val()
    _.each @model.radioKeys, (name) =>
      attributes[name] = @$("[name='#{name}']:checked").val()
    attributes

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

