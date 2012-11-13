class ChefSteps.Views.EditProfile extends Backbone.View
  getProfileValues: =>
    attributes = {}
    _.each @model.formKeys, (name) =>
      attributes[name] = @$("[name='#{name}']").val()
    attributes

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

