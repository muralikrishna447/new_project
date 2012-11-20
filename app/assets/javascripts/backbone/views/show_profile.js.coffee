class ChefSteps.Views.ShowProfile extends Backbone.View

  initialize: =>
    @model.bind('change', @updateValues)

  updateValues: =>
    _.each @model.attributes, (value, name) =>
      value = if name == 'chef_type' then @model.chefType() else value
      @$("[data-attribute=profile-#{name}]").text(value)

  show: =>
    @$el.show()

  hide: =>
    @$el.hide()

  checkEmptyValues: =>
    _.each @model.attributes, (value, name) =>
      $invisibleTags = @$("[data-attribute-invisible=profile-#{name}]")
      if value == ''
        $invisibleTags.addClass('invisible')
      else
        $invisibleTags.removeClass('invisible')

