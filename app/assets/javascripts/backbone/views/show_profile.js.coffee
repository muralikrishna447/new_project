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

  checkEmptyValues: =>
    _.each @model.attributes, (value, name) =>
       $field =  $("[data-attribute=profile-#{name}]")
       if $field.text() == ''
         $field.parent().addClass('invisible')
       else
         $field.parent().removeClass('invisible')

