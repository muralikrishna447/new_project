class ChefSteps.Views.Checkbox extends Backbone.View
  events:
    'click': 'select'

  initialize: (options)->
    @isRadio = @$el.data('behavior') == 'radio'

    @$input = @$('input')

    @$el.toggleClass('active', @isChecked())

  select: ()->
    if @isChecked()
      @$input.removeAttr('checked')
    else
      @$input.attr('checked', true)
    @$el.toggleClass('active', @isChecked())
    @clearOthers() if @isRadio
    @$input.trigger('change')

  isChecked: ->
    @$input.attr('checked') && true || false

  clearOthers: ->
    otherInputs = $("[name='#{@$input.attr('name')}'][checked]").not(@$input)
    otherInputs.removeAttr('checked')
    otherInputs.parent().removeClass('active')

