class ChefSteps.Views.EditProfile extends Backbone.View
  getProfileValues: =>
    attributes = {}
    _.each @model.attributes, (value, name) =>
      attributes[name] = @$("[name='#{name}']").val()
    attributes

  updateModel: =>
    @model.save(@getProfileValues())
    @hide()

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

